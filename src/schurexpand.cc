// schurexpand.cc
//
// Implement the Schur expansion of a polynomial, n, in the orthogonal 
// basis, S, using the MPFR arbitrary precision floating-point library. 
//
// Compile with:
//   mkoctfile -lgmp -lmpfr schurexpand.cc
//
// Octave function file schurexpand.m shows the original Octave code.
//

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

// Test in Octave with:
#if 0
fc=0.05;
[n,d]=butter(3,2*fc)
%   n = 6.0086e-08   1.8026e-07   1.8026e-07   6.0086e-08
%   d = 1.00000  -2.98429   2.96871  -0.98441
[S,k]=schurdecomp(d)
%   S =  0.07045   0.00000   0.00000   0.00000
%       -0.30483   0.31286   0.00000   0.00000
%        0.78677  -1.59152   0.84670   0.00000
%       -0.53208   1.92936  -2.37409   1.00000
%   k = -0.97432   0.92923  -0.53208
c=schurexpand(n,S)
%   c =  0.3053850 0.1034929 0.0183952 0.0028982
#endif

#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(schurexpand, args, nargout, "c=schurexpand(n,S,verbose)")
{
  if ((args.length() < 2) || (nargout != 1))
    {
      print_usage();
      return octave_value();
    }
  if(args(1).rows() != args(1).columns())
    {
      error("expected S to be a square matrix!");
      return octave_value();
    }
  if(args(0).length() > args(1).rows())
    {
      error("expected length(n)<=rows(S)!");
      return octave_value();
    }

  // For testing
  bool verbose = false;
  if (args.length() == 3)
    {
      verbose = true;
    }

  // Input arguments
  uint64_t nN = args(0).length();
  RowVector n = args(0).vector_value();
  uint64_t nS = args(1).rows();
  Matrix S = args(1).matrix_value();

  // Set precision to use
  mpfr_prec_t prec = 256;

  // Allocate and initialise mpfr
  mpfr_t mtmp;
  mpfr_t mnn[nN];
  mpfr_t mc[nS];
  mpfr_t mS[nS];
  mpfr_init2(mtmp, prec);
  for (uint64_t l=0;l<nN;l++)
    {
      mpfr_init2(mnn[l], prec);
      mpfr_set_d(mnn[l], n(nN-1-l), MPFR_RNDN);
    }
  for (uint64_t l=0;l<nS;l++)
    {
      mpfr_init2(mc[l], prec);
      mpfr_set_d(mc[l], 0, MPFR_RNDN);
      mpfr_init2(mS[l], prec);
      mpfr_set_d(mS[l], 0, MPFR_RNDN);
    }

  // For testing
  if (verbose)
    {
      for (uint64_t l=0;l<nN;l++)
        {
          mpfr_printf("mnn[%ju]=%16.16RNf\n", l, mnn[l]);
        }
    }

  // Expand recursively in the Schur basis
  for (uint64_t k=1;k<=nN;k++)
    {
      uint64_t nk=nN-k;

      // Initialise mS with current row of S
      for (uint64_t l=0;l<=nk;l++)
        {
          mpfr_set_d(mS[l], S(nk,l), MPFR_RNDN);
        }

      // c
      mpfr_div(mc[nk], mnn[nk], mS[nk], MPFR_RNDN);

      // Polynomial subtraction
      for (uint64_t l=0;l<nk;l++)
        {
          mpfr_mul(mtmp, mc[nk], mS[l], MPFR_RNDN);
          mpfr_sub(mnn[l], mnn[l], mtmp, MPFR_RNDN);
        }

      // For testing
      if (verbose)
        {
          printf("nk=%ju\n",nk);
          for (uint64_t l=0;l<nN;l++)
            { 
              mpfr_printf("mnn[%ju]=%16.16RNf\n", l, mnn[l]);
            }
          for (uint64_t l=0;l<nS;l++)
            {
              mpfr_printf("mc[%ju]=%16.16RNf\n", l, mc[l]);
              mpfr_printf("mS[%ju]=%16.16RNf\n", l, mS[l]);
            }
        }
    }

  // Copy output
  RowVector c(nS);
  for (uint64_t l=0;l<nS;l++)
    {
      c(l) = mpfr_get_d(mc[l], MPFR_RNDN);
    }

  // Deallocate
  mpfr_clear(mtmp);
  for (uint64_t l=0;l<nN;l++)
    {
      mpfr_clear(mnn[l]);
    }
  for (uint64_t l=0;l<nS;l++)
    {
      mpfr_clear(mc[l]);
      mpfr_clear(mS[l]);
    }

  // Done
  return octave_value(c);
}
