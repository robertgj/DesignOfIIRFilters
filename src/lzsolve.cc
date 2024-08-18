// lzsolve.cc
//
// Find the roots of a polynomial by calling LAPACK DGEEV compiled with 16 byte
// REALs. Compare with the builtin octave function "roots":
/*
  n=20
  p=bincoeff(n,0:n)
  A=[-p(2:end)/p(1);eye(n-1),zeros(n-1,1)]
  any(any(A-compan(p)))
  any(roots(p)-eigs(A,n))
*/ 
// Based on the answer at:
/*
https://scicomp.stackexchange.com/questions/26395/how-to-start-using-lapack-in-c
*/
// Also based on poly/companion.c from the GNU Scientific Library, gsl-2.4.
// Here is the copyright notice from that file:
// 
// Copyright (C) 1996, 1997, 1998, 1999, 2000, 2007 Brian Gough
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
// Compile BLAS and LAPACK static libraries with "-freal-8-real-16" and a patched
// version of INSTALL/make.inc.gfortran-quad.

#include <cstdio>
#include <cstdlib>
#include <quadmath.h>

// dgeev_ is a symbol in the LAPACK library files
extern "C"
{
  extern int dgeev_ (char*, char*, int*, __float128*, int*, __float128*,
                     __float128*, __float128*, int*, __float128*, int*,
                     __float128*, int*, int*);
}
/* C-style matrix elements (row i of 0 to n-1, column j of 0 to n-1 */
#define MAT(m,i,j,n) ((m)[(i)*(n) + (j)])

static void
set_companion_matrix (const __float128 *a, size_t nc, __float128 *m)
{
  size_t i, j;

  for (i = 0; i < nc; i++) {
    for (j = 0; j < nc; j++) {
      MAT (m, i, j, nc) = 0.0;
    }
  }

  for (i = 1; i < nc; i++) {
    MAT (m, i, i - 1, nc) = 1.0;
  }
    
  for (i = 0; i < nc; i++) {
    MAT (m, i, nc - 1, nc) = -a[i] / a[nc];
  }
}

#if defined(TEST_LZSOLVE)

//Compile with:
/*
g++ -o lzsolve src/lzsolve.cc -L$OCTAVE_LIB_DIR \
-lqlapack -lqblas -lgfortran  -lquadmath -DTEST_LZSOLVE
*/
static __float128 qhypot (const __float128 x, const __float128 y)
{
  __float128 xabs = fabsq(x) ;
  __float128 yabs = fabsq(y) ;
  __float128 min, max;

  if (xabs < yabs) {
    min = xabs ;
    max = yabs ;
  } else {
    min = yabs ;
    max = xabs ;
  }

  if (min == 0) 
    {
      return max ;
    }

  __float128 u = min / max ;
  return max * sqrtq (1 + u * u) ;
}

int main(void)
{
  // Order 20 binomial coefficients
  int n=20;
  __float128 p[n+1] = {      1,     20,    190,     1140,     4845,
                           15504,  38760,  77520,   125970,   167960,
                          184756,
                          167960, 125970,  77520,    38760,    15504,
                            4845,   1140,    190,       20,        1 };
  
  // Print p
  printf("p=");
  for (size_t i = 0; i < n+1; i++) {
    size_t width=16;
    char buf[128];
    quadmath_snprintf (buf, sizeof(buf), "%6.0Qf", p[i]);
    printf("%s ", buf);
  }
  printf("\n");

  // Make companion matrix of p
  __float128 *data = (__float128 *)calloc(n*n,sizeof(__float128));
  set_companion_matrix(p,n,data);
  
  // Allocate data storage
  char Nchar='N';
  __float128 *eigReal = (__float128 *)calloc(n,sizeof(__float128));
  __float128 *eigImag = (__float128 *)calloc(n,sizeof(__float128));
  __float128 *vl=NULL;
  __float128 *vr=NULL;
  int one=1;
  int lwork=6*n;
  __float128 *work = (__float128 *)calloc(6*n,sizeof(__float128));
  int info;

  // Calculate eigenvalues using the DGEEV subroutine
  dgeev_(&Nchar,&Nchar,&n,data,&n,eigReal,eigImag,
         vl,&one,vr,&one,work,&lwork,&info);

  if (info) {
    fprintf(stderr, "Error: dgeev returned error code %d\n",info);
    return -1;
  }

  // Print eigenvalues to stdout
  for (size_t i = 0; i < n; i++) {
    size_t width=36;
    char bufr[128];
    char bufi[128];
    char bufm[128];

    quadmath_snprintf (bufr, sizeof(bufr), "%+-#*.30Qe", width, eigReal[i]);
    quadmath_snprintf (bufi, sizeof(bufi), "%+-#*.30Qe", width, eigImag[i]);
    __float128 m = qhypot(eigReal[i],eigImag[i]);
    quadmath_snprintf (bufm, sizeof(bufm),"%+-#*.30Qe",width, m);
    printf ("z%d=%s %s \n(%s)\n", i, bufr, bufi, bufm);
  }

  // Done
  free(work);
  free(eigImag);
  free(eigReal);
  free(data);
  
  return 0;
}

#else

#include <octave/oct.h>

DEFUN_DLD(lzsolve, args, nargout, "r=lzsolve(p)")
{

  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin!=1) || (nargout>1))
    {
      print_usage();
    }
  if (args(0).is_complex_scalar() || args(0).is_complex_matrix())
    {
      error("Expected real argument!");
      return octave_value();
    }

  // Input arguments
  ColumnVector p = args(0).column_vector_value();
  
  if (p.numel()<=1)
    {
      Matrix r;
      octave_value_list retval(1);
      retval(0)=r;
      return retval;
    }

  // Count the leading zero coefficients 
  octave_idx_type num_leading_zeros=0;
  for(auto row=0;row<p.numel();row++)
    {
      if (p(row) != 0)
        {
          break;
        }
      num_leading_zeros++;
    }
  if (num_leading_zeros == p.numel())
    {
      octave_value_list retval(1);
      retval(0)=0;
      return retval;      
    }

  // Initialise arguments. 
  int n=p.numel()-num_leading_zeros-1;
  __float128 a[n+1];
  for(auto row=0;row<=n;row++)
    {
      a[row]=p(p.numel()-1-row);
    }

  // Make companion matrix of p
  __float128 data[n*n];
  set_companion_matrix(a,n,data);
  
  // Call DGEEV. For an order n polynomial I expect n zeros.
  // Allocate data storage
  char Nchar='N';
  __float128 eigReal[n*n];
  __float128 eigImag[n*n];
  __float128 *vl=NULL;
  __float128 *vr=NULL;
  int one=1;
  int lwork=6*n;
  __float128 work[6*n];
  int info;

  // Calculate eigenvalues using the DGEEV subroutine
  dgeev_(&Nchar,&Nchar,&n,data,&n,eigReal,eigImag,
         vl,&one,vr,&one,work,&lwork,&info);

  if (info)
    {
      octave_value_list retval(0);
      return retval;
    }
  
  // Done
  ComplexColumnVector r(n);
  for(auto row=0;row<n;row++)
    {
      double tmpr=eigReal[row];
      double tmpi=eigImag[row];
      std::complex<double> tmp;
      tmp.real(tmpr);
      tmp.imag(tmpi);
      r(row)=tmp;
    }
  octave_value_list retval(1);
  retval(0)=r;

  return retval;
}

#endif
