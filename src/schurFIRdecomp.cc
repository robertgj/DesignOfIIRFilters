// schurFIRdecomp.cc
//
// Implement the Schur recursion for degree reduction of an FIR Schur
// polynomial and calculation of Schur FIR lattice coefficients
// with the MPFR arbitrary precision floating-point library.
//
// Compile with:
//   mkoctfile -lgmp -lmpfr schurFIRdecomp.cc
//
// Octave function file schurFIRdecomp.m shows the original Octave code.
//
// Test in Octave with:
//   fc=0.05;
//   [n,d]=butter(3,0.05*fc)
//   n =
//      6.0086e-08   1.8026e-07   1.8026e-07   6.0086e-08
//   d =
//       1.00000  -2.98429   2.96871  -0.98441
//
//   k=schurFIRdecomp(d)
//   k =
//     -0.97432   0.92923  -0.53208


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

DEFUN_DLD(schurFIRdecomp, args, nargout, "k=schurFIRdecomp(d)")
{
  if ((args.length() < 1) || (nargout != 1))
    {
      print_usage();
      return octave_value_list();
    }

  // Input arguments
  uint64_t N = args(0).length();
  RowVector d = args(0).vector_value();

  // Sanity checks
  if (d(0) != 1)
    {
      error("Expect d(0)==1!");
      return octave_value();
    }
  if (d(N-1) >= 1)
    {
      error("Expect d(N-1)<1!");
      return octave_value();
    }
        
  // Output arguments
  RowVector k(N-1);
  for (uint64_t l=0;l<N-1;l++)
    {
      k(l)=0;
    }

  // Set precision to use
  mpfr_prec_t prec = 1024;

  // Allocate and initialise mpfr
  mpfr_t mk;
  mpfr_t m1_k2;
  mpfr_t mdnext[N];
  mpfr_t mdrev[N];
  mpfr_init2(mk, prec);
  mpfr_init2(m1_k2, prec);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_init2(mdnext[l],prec);
      mpfr_init2(mdrev[l],prec);
    }

  // Set inital values
  mpfr_set_d(mk, 0, MPFR_RNDN);
  mpfr_set_d(m1_k2, 0, MPFR_RNDN);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_set_d(mdnext[l], d(l), MPFR_RNDN);
    }

  // Schur recursion
  for (uint64_t i=N-1;i>0;i--)
    {
      // Copy k from d(N-1-i) (By assumption d(0)==1);
      k(i-1)=mpfr_get_d(mdnext[i], MPFR_RNDN);
      mpfr_set(mk, mdnext[i], MPFR_RNDN);
      if (mpfr_cmp_d(mk, 1.0) > 0)
        {
          // k<1 for Schur polynomials
          mpfr_fprintf(stderr, "N=%lu, i=%lu, mk=%.32RNf\n",N,i,mk);
          warning("mk > 1.0. d() is not a Schur polynomial?");
          // Deallocate
          mpfr_clear(mk);
          mpfr_clear(m1_k2);
          for (uint64_t l=0;l<N;l++)
            {
              mpfr_clear(mdnext[l]);
              mpfr_clear(mdrev[l]);
            }
          return octave_value();
        }

      // Calculate 1-k^2
      mpfr_mul(m1_k2, mk, mk, MPFR_RNDN);
      mpfr_d_sub(m1_k2, 1.0, m1_k2, MPFR_RNDN);
      // Make the reversed polynomial
      for (uint64_t l=0;l<=i;l++)
        {
          mpfr_mul(mdrev[l], mk, mdnext[i-l], MPFR_RNDN);
        } 
      // Schur polynomial order reduction
      for (uint64_t l=1;l<i;l++)
        {
          mpfr_sub(mdnext[l], mdnext[l], mdrev[l], MPFR_RNDN);
          mpfr_div(mdnext[l], mdnext[l], m1_k2, MPFR_RNDN);
        }

    }

  // Deallocate
  mpfr_clear(mk);
  mpfr_clear(m1_k2);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_clear(mdnext[l]);
      mpfr_clear(mdrev[l]);
    }

  // Done
  return octave_value(k);
}
