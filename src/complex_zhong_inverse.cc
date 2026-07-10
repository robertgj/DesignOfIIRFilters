// complex_zhong_inverse.cc
//
// Use the algorithm of Xu Zhong to calculate the inverse of a lower
// Hessenberg matrix with complex coefficients. See Theorem 1 of
// "On Inverses and Generalized Inverses of Hessenberg Matrices",
// Xu Zhong, "Linear Algebra and its Applications", Vol. 101, 1988,
// pp. 167-180. This implementation finds the inverse of the lower
// triangular part by calling the LAPACK ZTRTRI function for finding
// the inverse of a triangular matrix with COMPLEX*16 elements. The
// octave Array<Complex> type contains 16 byte complex values consisting
// of interleaved pairs of 8 byte doubles as in the Fortran convention.
// In one test of the matrix resolvent (e^(j*w(1:1024))-A)^(-1) of the
// state transition matrix, A(1:20,1:20), of a Schur lattice filter,
// the octave profile time for "inv" was 61ms and 26ms for this function.
//
// Compile with:
//   mkoctfile complex_zhong_inverse.cc
//
// Test with address-sanitizer (and a release build of octave):
#if 0
   mkoctfile -O0 -g \
     -fsanitize=address -fsanitize=undefined \
     -fno-sanitize=vptr -fno-omit-frame-pointer \
     -o src/complex_zhong_inverse.oct src/complex_zhong_inverse.cc
   ASAN_OPTIONS='stack_trace_format="[frame=%n, function=%f, location=%S]"' \
   ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer \
   LD_PRELOAD=/usr/lib64/libasan.so.8 \
     octave-cli -q -p src \
     --eval "N=5, \
             r=reprand(2*N*N); \
             A=hess(reshape(r(1:(N*N)),N,N)+ \
                    j*reshape(r(((N*N)+1):(2*N*N)),N,N))', \
             B=complex_zhong_inverse(A), \
             C=complex_zhong_inverse(A), \
             max(max(abs((B-C))))/eps, \
             max(max(abs((C*A)-eye(N))))/eps, \
             max(max(abs((A*C)-eye(N))))/eps" \
     > asan.out 2>&1; grep -i zhong asan.out
#endif

// Copyright (C) 2017-2026 Robert G. Jenssen
//
// This program is free software; you can redistribute it and/or 
// modify it underthe terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/builtin-defun-decls.h>
#include <octave/f77-fcn.h>

#undef COMPLEX_ZHONG_INVERSE_USE_CACHE
#undef COMPLEX_ZHONG_INVERSE_USE_CACHE_VERBOSE

#if defined(COMPLEX_ZHONG_INVERSE_USE_CACHE)

// As of aegis change 1721 all tests pass with the cache enabled
//
// For schurOneMAPlattice_frm_hilbert_socp_slb_test.m, running the
// profiler on the PCLS loop without caching:
/*
   #                Function Attr     Time (s)   Time (%)        Calls
----------------------------------------------------------------------
  26    schurOneMAPlattice2H            22.594      24.15         3960
 157                  asmDxq             6.344       6.78        47065
  27   complex_zhong_inverse             6.309       6.74      1906081
 160                 wrapPcg             5.108       5.46        12301
 108                   clear             3.808       4.07         9154
  85                  sedumi             3.515       3.76          226
 167                 wregion             3.368       3.60         4012
 173                 maxstep             2.638       2.82        16048
 
 */
// and with caching:
/*
  26    schurOneMAPlattice2H            20.002      21.43         3960
  27   complex_zhong_inverse             6.413       6.87      1906081
 157                  asmDxq             5.974       6.40        47065
 160                 wrapPcg             5.083       5.45        12301
 108                   clear             4.336       4.65         9154
  85                  sedumi             4.060       4.35          226
 167                 wregion             3.611       3.87         4012
 173                 maxstep             2.614       2.80        16048
  */

// Create a static std::unordered_map
#include <unordered_map>
static std::unordered_map<u_int64_t,ComplexMatrix> complex_zhong_inverse_cache;
     
// The FNV-1a hash function.
// See:
//     [1] https://github.com/lcn2/fnv and
//     [2] https://www.rfc-editor.org/rfc/rfc9923.pdf
#include <stdint.h>
#include <sys/types.h>
extern "C"
{
  static u_int64_t fnv_64a_buf(void *buf, size_t len)
  {
    unsigned char *bp = (unsigned char *)buf;   /* start of buffer */
    unsigned char *be = bp + len;               /* beyond end of buffer */
    u_int64_t hval = ((u_int64_t)0xcbf29ce484222325ULL);
    #define FNV_64_PRIME = ((u_int64_t)0x100000001b3ULL);

    /* FNV-1a hash each octet of the buffer */
    while (bp < be)
      {
        /* xor the bottom with the current octet */
        hval ^= (u_int64_t)*bp++;

        /* Multiply by the 64 bit FNV magic prime mod 2^64 */
        hval += (hval << 1) + (hval << 4) + (hval << 5) +
          (hval << 7) + (hval << 8) + (hval << 40);
      }

    /* return our new hash value */
    return hval;
  }
}

#endif

// Interface to the LAPACK ZTRTRI function
extern "C"
{
  F77_RET_T
  F77_FUNC (ztrtri, ZTRTRI) (F77_CONST_CHAR_ARG_DECL UPLO,
                             F77_CONST_CHAR_ARG_DECL DIAG,
                             const octave_idx_type& N,
                             Complex* A,
                             const octave_idx_type& LDA,
                             octave_idx_type& INFO
                             F77_CHAR_ARG_LEN_DECL
                             F77_CHAR_ARG_LEN_DECL);
}

DEFUN_DLD(complex_zhong_inverse,args,nargout,"B=complex_zhong_inverse(A)")
{ 
  if ((args.length() != 1) || (nargout != 1))
    {
      print_usage();
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }   
  if (args(0).rows() != args(0).columns())
    {
      error("complex_zhong_inverse.cc: A.rows()~=A.columns()");
      return octave_value_list();
    }
  if (args(0).rows() == 0)
    {
      error("complex_zhong_inverse.cc: A is empty!");
      return octave_value_list();
    }
  if (args(0).rows() <= 2)
    {
      return octave::feval("inv",args(0),1);
    }

  ComplexMatrix A=args(0).complex_matrix_value();
  const octave_idx_type N=A.columns();

#if defined(COMPLEX_ZHONG_INVERSE_USE_CACHE)
  // Check the cache
  u_int64_t fnv64a_key = fnv_64a_buf(A.rwdata(), A.byte_size());
  auto node=complex_zhong_inverse_cache.extract(fnv64a_key);
  if (!node.empty())
    {
      ComplexMatrix &B = node.mapped();
      if ((B.rows() != N) || (B.columns() != N))
        {
          error("complex_zhong_inverse.cc: cached inverse has wrong size!");
          return octave_value_list();
        }
#if defined(COMPLEX_ZHONG_INVERSE_USE_CACHE_VERBOSE)
      warning("Cached inverse found!");
#endif
      octave_value_list retval(1);
      retval(0)=B;
      return octave_value_list(retval);
    }
#endif
  
  // Arguments to ZTRTRI
  const char UPLO = 'L';
  const char DIAG = 'N';
  const octave_idx_type LDA=N-1;
  octave_idx_type INFO=0;
  Array<Complex> P(dim_vector(N-1,N-1));
  Complex *pP=P.fortran_vec();
  // Initialise the lower triangular part, P
  for (octave_idx_type i=0;i<N-1;i++)
    { 
      for (octave_idx_type j=0;j<=i;j++)
        {
          P.elem(i,j)=A.elem(i,j+1);
        }
    }
  // Call ZTRTRI to find the inverse of P
  F77_XFCN ( ztrtri, ZTRTRI, (F77_CONST_CHAR_ARG2 (&UPLO, 1),
                              F77_CONST_CHAR_ARG2 (&DIAG, 1),
                              N-1, pP, LDA, INFO
                              F77_CHAR_ARG_LEN (1)
                              F77_CHAR_ARG_LEN (1)) );
  if (INFO)
    {
      error("complex_zhong_inverse.cc: INFO=%ld",INFO);
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }

  // alpha
  OCTAVE_LOCAL_BUFFER (Complex, alpha, N-1);
  for (int i=0;i<(N-1);i++)
    {
      alpha[i]=A.elem(i,i+1);
    }

  // xi recurrence
  OCTAVE_LOCAL_BUFFER (Complex, xi, N);
  xi[0]=1;
  for (int i=2;i<=N;i++)
    {
      xi[i-1]=0;
      for(int k=1;k<=(i-1);k++)
        {
          xi[i-1]=xi[i-1]+(A.elem(i-2,k-1)*xi[k-1]);
        }
      xi[i-1]=-xi[i-1]/alpha[i-2];
    }
                      
  // wi recurrence
  OCTAVE_LOCAL_BUFFER (Complex, wi, N);
  wi[N-1]=0;
  for(int k=1;k<=N;k++)
    {
      wi[N-1]=wi[N-1]+(A.elem(N-1,k-1)*xi[k-1]);
    }
  wi[N-1]=Complex(1)/wi[N-1];
  for (int i=N-1;i>=1;i--)
    {
      wi[i-1]=0;
      for(int k=i+1;k<=N;k++)
        {
          wi[i-1]=wi[i-1]+(A.elem(k-1,i)*wi[k-1]);
        }
      wi[i-1]=-wi[i-1]/alpha[i-1];
    }

  // Construct inverse
  Array<Complex> B(dim_vector(N,N));
  for(int k=0;k<N-1;k++)
    {
      for (int i=0;i<N-1;i++)
        {
          B.elem(i+1,k)=P.elem(i,k);
        }
    }
  for(int k=0;k<N;k++)
    {
      for (int i=0;i<N;i++)
        {
          B.elem(i,k)=B.elem(i,k)+(xi[i]*wi[k]);
        }
    }

#if defined(COMPLEX_ZHONG_INVERSE_USE_CACHE)
  // Cache the inverse
  bool ok = complex_zhong_inverse_cache.insert({fnv64a_key,B}).second;
  if (!ok)
    {
      error("complex_zhong_inverse.cc: caching inverse failed!");
      return octave_value_list();
    }
#endif
  
  // Done
  octave_value_list retval(1);
  retval(0)=B;
  return octave_value_list(retval);
}
