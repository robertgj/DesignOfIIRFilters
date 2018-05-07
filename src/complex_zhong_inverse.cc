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
   mkoctfile -O0 -g -fsanitize=address -fsanitize=undefined \
     -fno-sanitize=vptr -fno-omit-frame-pointer complex_zhong_inverse.cc
   LD_PRELOAD=/usr/lib64/libasan.so.5 octave-cli  \
     --eval "N=4, \
             r=reprand(2*N*N); \
             A=hess(reshape(r(1:(N*N)),N,N)+ \
                    j*reshape(r(((N*N)+1):(2*N*N)),N,N))', \
             B=complex_zhong_inverse(A), \
             max(max(abs((B*A)-eye(N))))/eps, \
             max(max(abs((A*B)-eye(N))))/eps"
#endif


// Copyright (C) 2017 Robert G. Jenssen
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
      return feval("inv",args(0),1);
    }

  ComplexMatrix A=args(0).complex_matrix_value();
  const octave_idx_type N=A.columns();

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
      warning("complex_zhong_inverse.cc: INFO=%ld",INFO);
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

  // xi recursion
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
                      
  // wi recursion
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
  for (int i=0;i<N-1;i++)
    {
      for(int k=0;k<N-1;k++)
        {
          B.elem(i+1,k)=P.elem(i,k);
        }
    }
  for (int i=0;i<N;i++)
    {
      for(int k=0;k<N;k++)
        {
          B.elem(i,k)=B.elem(i,k)+(xi[i]*wi[k]);
        }
    }

  // Done
  octave_value_list retval(1);
  retval(0)=B;
  return octave_value_list(retval);
}
