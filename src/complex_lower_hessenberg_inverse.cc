// complex_lower_hessenberg_inverse.cc
//
// Calculate the inverse of a lower Hessenberg matrix with complex
// coefficients by calling the LAPACK ZGBSV function for finding the
// inverse of a banded matrix with COMPLEX*16 elements. The octave
// Array<Complex> type contains 16 byte complex values consisting of
// interleaved pairs of 8 byte doubles as in the Fortran convention.
// In one test of the matrix resolvent (e^(j*w(1:1024))-A)^(-1) of the
// state transition matrix, A(1:20,1:20), of a Schur lattice filter,
// the octave profile time for "inv" was 61ms and 42ms for this function.
//
// Compile with:
//   mkoctfile complex_lower_hessenberg_inverse.cc
//
// Test with address-sanitizer:
#if 0
mkoctfile -g -fsanitize=address -fsanitize=undefined \
-fno-sanitize=vptr -fno-omit-frame-pointer complex_lower_hessenberg_inverse.cc
LD_PRELOAD=/usr/lib64/libasan.so.3 octave \
  --eval "N=4, \
          r=reprand(2*N*N); \
          A=hess(reshape(r(1:(N*N)),N,N)+ \
                 j*reshape(r(((N*N)+1):(2*N*N)),N,N))', \
          B=complex_lower_hessenberg_inverse(A), \
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
#include <octave/builtin-defun-decls.h>
#include <octave/f77-fcn.h>

extern "C"
{
  F77_RET_T
  F77_FUNC (zgbsv, ZGBSV) (const octave_idx_type& N,
                           const octave_idx_type& KL,
                           const octave_idx_type& KU,
                           const octave_idx_type& NRHS,
                           Complex* AB,
                           const octave_idx_type& LDAB,
                           octave_idx_type* IPIV,
                           Complex* B,
                           octave_idx_type& LDB,
                           octave_idx_type& INFO);
}

DEFUN_DLD(complex_lower_hessenberg_inverse, args, nargout,
          "B=complex_lower_hessenberg_inverse(A)")
{ 
  if ((args.length() !=1) || (nargout > 1))
    {
      print_usage();
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }   
  if (args(0).rows() != args(0).columns())
    {
      warning("complex_lower_hessenberg_inverse.cc: A.rows()~=A.columns()");
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }

  // Arguments to CGBSV
  ComplexMatrix A=args(0).complex_matrix_value();
  const octave_idx_type N=A.columns();
  const octave_idx_type KL=N-1;
  const octave_idx_type KU=1;
  const octave_idx_type NRHS=N;
  Array<Complex> AB(dim_vector(2*N,N));
  Complex *pAB=AB.fortran_vec();
  // Initialise AB following "man zgbsv". For parameter AB:
  //   "AB is COMPLEX*16 array, dimension (LDAB,N)
  //    On entry, the matrix A in band storage, in rows KL+1 to
  //    2*KL+KU+1; rows 1 to KL of the array need not be set.
  //    The j-th column of A is stored in the j-th column of the
  //    array AB as follows:
  //    AB(KL+KU+1+i-j,j) = A(i,j) for max(1,j-KU)<=i<=min(N,j+KL)"
  for (octave_idx_type j=0;j<N;j++)
    {
      octave_idx_type imin=( (j-KU)>0  ?  (j-KU) :     0  );
      octave_idx_type imax=( (j+KL)>=N ?   (N-1) : (j+KL) );
      for (octave_idx_type i=imin;i<=imax;i++)
        {
          AB.elem(KL+KU+i-j,j)=A.elem(i,j);
        }
    }
  const octave_idx_type LDAB=2*N;
  Array<octave_idx_type>IPIV(dim_vector(N,1));
  octave_idx_type* pIPIV=IPIV.fortran_vec();
  Array<Complex> B(dim_vector(N,N));
  for (octave_idx_type i=0;i<N;i++)
    {
      B.elem(i,i)=1;
    }
  Complex* pB=B.fortran_vec();
  octave_idx_type LDB=N;
  octave_idx_type INFO=0;

  // Call ZGBSV   
  F77_XFCN ( zgbsv, ZGBSV, (N, KL, KU, NRHS, pAB, LDAB, pIPIV, pB, LDB, INFO ));
  if (INFO)
    {
      warning("complex_lower_hessenberg_inverse.cc: ZGBSV INFO=%ld",INFO);
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }
  
  // Done
  octave_value_list retval(1);
  retval(0)=B;
  return octave_value_list(retval);
}
