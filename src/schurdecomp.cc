// schurdecomp.cc
//
// Implement the Schur recurrence for decomposing a polynomial into an
// orthonormal basis with the MPFR arbitrary precision floating-point
// library.
//
// Compile with:
//   mkoctfile -lgmp -lmpfr schurdecomp.cc
//
// Octave function file schurdecomp.m shows the original Octave code.
//
// Test in Octave with:
//   fc=0.05;
//   [n,d]=butter(3,2*fc)
//   n =
//      2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03
//   d =
//      1.0000e+00  -2.3741e+00   1.9294e+00  -5.3208e-01
//
//   [k,S]=schurdecomp(d/n(1))
//   k =
//     -0.97432   0.92923  -0.53208
//
//   S =
//     24.30894     0.00000     0.00000     0.00000
//   -105.17884   107.95144     0.00000     0.00000
//    271.47003  -549.14060   292.14635     0.00000
//   -183.58856   665.70949  -819.16332   345.04239
//

// Copyright (C) 2017-2025 Robert G. Jenssen
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

#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(schurdecomp, args, nargout, "[k,S]=schurdecomp(d)")
{
  if ((args.length() < 1) || (nargout > 2))
    {
      print_usage();
      return octave_value_list();
    }

  // Input arguments
  uint64_t N = args(0).length();
  RowVector d = args(0).vector_value();
  // Sanity checks
  if (N == 0)
    {
      error("d is empty");
      octave_value_list retval;
    }
  if (d(0)==0)
    {
      error("First element of d is 0");
      return octave_value_list();
    }
  if (N == 1)
    {
      if (nargout == 1)
        {
          octave_value_list retval(1);
          Matrix k(0,0);
          retval(0)=k;
          return octave_value_list(retval);
        }
      else if (nargout == 2)
        {
          octave_value_list retval(2);
          Matrix k(0,0);
          retval(0)=k;
          retval(1)=args(0).vector_value();
          return octave_value_list(retval);
        }
      else
        {
          return octave_value_list();
        }
    }
  
  // Output arguments
  RowVector k(N-1);
  for (uint64_t l=0;l<N-1;l++)
    {
      k(l)=0;
    }
  Matrix S(N,N);
  for (uint64_t m=0;m<N;m++)
    {
      for (uint64_t l=0;l<N;l++)
        {
          S(m,l)=0;
        }
    }

  // Set precision to use
  mpfr_prec_t prec = 256;

  // Allocate and initialise mpfr
  mpfr_t mtmp;
  mpfr_t mk;
  mpfr_t msqrt1_k2;
  mpfr_t mSnext[N];
  mpfr_t mS[N];
  mpfr_init2(mtmp, prec);
  mpfr_init2(mk, prec);
  mpfr_init2(msqrt1_k2, prec);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_init2(mSnext[l],prec);
      mpfr_init2(mS[l], prec);
    }

  // Set inital values
  mpfr_set_d(mtmp, 0, MPFR_RNDN);
  for (uint64_t l=0;l<N;l++)
    {
      S(N-1,l)=d(N-1-l);
      mpfr_set_d(mS[l], S(N-1,l), MPFR_RNDN);
    }

  // Schur recurrence
  for (uint64_t i=0;i<N-1;i++)
    {
      // k
      mpfr_div(mk, mS[0], mS[N-1-i], MPFR_RNDN);
      if (mpfr_cmp_d(mk, 1.0) > 0)
        {
          // k<1 for Schur polynomials
          mpfr_fprintf(stderr, "%s(line %d) : N=%lu, i=%lu\n"
                       " mk = %.32RNf\n"
                       " mS[0] = %.32RNf\n"
                       " mS[N-1-%lu] = %.32RNf\n", 
                       __FILE__, __LINE__, N, i, mk, mS[0], i, mS[N-1-i]);
          warning("mk > 1.0. Not a Schur polynomial?");
          // Deallocate
          mpfr_clear(mtmp);
          mpfr_clear(mk);
          mpfr_clear(msqrt1_k2);
          for (uint64_t l=0;l<N;l++)
            {
              mpfr_clear(mSnext[l]);
              mpfr_clear(mS[l]);
            }
          // Construct a null return value
          octave_value_list retval(2);
          Matrix retval0(0,0);
          retval(0)=retval0;
          RowVector retval1(0);
          retval(1)=retval1;
          return octave_value_list(retval);
        }
      k(N-2-i) = mpfr_get_d(mk, MPFR_RNDN); 

      // sqrt(1-k^2)
      mpfr_mul(msqrt1_k2, mk, mk, MPFR_RNDN);
      mpfr_d_sub(msqrt1_k2, 1.0, msqrt1_k2, MPFR_RNDN);
      mpfr_sqrt(msqrt1_k2, msqrt1_k2, MPFR_RNDN);
      
      // Snext
      for (uint64_t l=0;l<N-1-i;l++)
        {
          // S
          mpfr_set(mSnext[l], mS[l+1], MPFR_RNDN);
          mpfr_mul(mtmp, mk, mS[(N-1-i)-(l+1)], MPFR_RNDN);
          mpfr_sub(mSnext[l], mSnext[l], mtmp, MPFR_RNDN);
          mpfr_div(mSnext[l], mSnext[l], msqrt1_k2, MPFR_RNDN);
        }

      // S output and copy
      for (uint64_t l=0;l<N-1-i;l++)
        {
          S(N-2-i,l)=mpfr_get_d(mSnext[l], MPFR_RNDN);
          mpfr_set(mS[l], mSnext[l], MPFR_RNDN);
        }
    }

  // Deallocate
  mpfr_clear(mtmp);
  mpfr_clear(mk);
  mpfr_clear(msqrt1_k2);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_clear(mSnext[l]);
      mpfr_clear(mS[l]);
    }

  // Done
  if (nargout == 1)
    {
      octave_value_list retval(1);
      retval(0)=k;
      return octave_value_list(retval);
    }
  else if (nargout == 2)
    {
      octave_value_list retval(2);
      retval(0)=k;
      retval(1)=S;
      return octave_value_list(retval);
    }
  else
    {
      return octave_value_list();
    }
}
