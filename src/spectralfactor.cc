// spectralfactor.cc
//
// Implement the spectral factor algorithm with the MPFR arbitrary 
// precision library floating-point. The Octave call is:
//   q=spectralfactor(n,d);
// where n,d and q are assumed to be row vectors of equal, even length.
//
// Compile with:
//   mkoctfile -lgmp -lmpfr spectralfactor.cc
//
// Octave function file spectralfactor.m shows the original Octave code.
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

#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(spectralfactor, args, nargout, "q=spectralfactor(n,d)")
{
  if ((args.length() < 2) || (nargout != 1))
    {
      print_usage();
      return octave_value();
    }
  if (args(0).length() != args(1).length())
    {
      error("expect filter numerator and denominator with equal order !");
      return octave_value();
    }
  if (args(0).length()%2 != 0)
    {
      error("expect odd filter order!");
      return octave_value();
    }

  // Set precision to use
  mpfr_prec_t prec = 256;

  // Input arguments
  uint64_t N = args(0).length();
  RowVector n = args(0).vector_value();
  RowVector d = args(1).vector_value();

  // Allocate and initialise
  mpfr_t mtmp;
  mpfr_t mn[N];
  mpfr_t mnn[N];
  mpfr_t mdd[N];
  mpfr_t md[N];
  mpfr_t mr[N]; 
  mpfr_t mq[N];
  mpfr_init2(mtmp, prec);
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_init2(mn[k], prec);
      mpfr_init2(mnn[k], prec);
      mpfr_init2(md[k], prec);
      mpfr_init2(mdd[k], prec);
      mpfr_init2(mr[k], prec);
      mpfr_init2(mq[k], prec);
    }

  // Set inital values
  mpfr_set_d(mtmp, 0, MPFR_RNDN);
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_set_d(mn[k], n(k), MPFR_RNDN);
      mpfr_set_d(md[k], d(k), MPFR_RNDN);
    }

  // Calculate mr corresponding to r
  // First, partial convolution of n
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_set_d(mnn[k], 0, MPFR_RNDN);
      for (uint64_t l=0;l<=k;l++)
        {
          mpfr_mul(mtmp, mn[l], mn[k-l], MPFR_RNDN);
          mpfr_add(mnn[k], mnn[k], mtmp, MPFR_RNDN);
        }
    }
  // Second, partial convolution of d and reversed d
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_set_d(mdd[k], 0, MPFR_RNDN);
      for (uint64_t l=0;l<=k;l++)
        {
          mpfr_mul(mtmp, md[l], md[N-1-k+l], MPFR_RNDN);
          mpfr_add(mdd[k], mdd[k], mtmp, MPFR_RNDN);
        }
    }
  // Subtract partial convolutions of n and d
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_sub(mr[k], mnn[k], mdd[k], MPFR_RNDN);
    }

  // Calculate spectral factor mq, corresponding to q
  mpfr_sqrt(mq[0], mr[0], MPFR_RNDN);
  mpfr_div(mq[1],  mr[1], mq[0], MPFR_RNDN);
  mpfr_div_d(mq[1], mq[1], 2.0, MPFR_RNDN);
  // q is anti-symmetric
  for(uint64_t k=2;k<=(N/2);k++)
    {
      mpfr_set_d(mq[k], 0, MPFR_RNDN);
      for(uint64_t l=1;l<k;l++)
        {
          mpfr_set_d(mtmp, 0, MPFR_RNDN);
          mpfr_mul(mtmp, mq[l], mq[k-l], MPFR_RNDN);
          mpfr_add(mq[k], mq[k], mtmp, MPFR_RNDN);
        }
      mpfr_sub(mq[k], mr[k], mq[k], MPFR_RNDN);
      mpfr_div(mq[k], mq[k], mq[0], MPFR_RNDN);
      mpfr_div_d(mq[k], mq[k], 2.0, MPFR_RNDN);
    }
  for(uint64_t k=((N/2)+1);k<=N;k++)
    {
      mpfr_neg(mq[k-1], mq[N-k], MPFR_RNDN);
    }

  // Output conversion
  RowVector q(N);
  for (uint64_t k=0;k<N;k++)
    {
      q(k) = mpfr_get_d(mq[k], MPFR_RNDN);
    }  

  // Deallocate
  mpfr_clear(mtmp);
  for (uint64_t k=0;k<N;k++)
    {
      mpfr_clear(mn[k]);
      mpfr_clear(mnn[k]);
      mpfr_clear(md[k]);
      mpfr_clear(mdd[k]);
      mpfr_clear(mr[k]);
      mpfr_clear(mq[k]);
    }

  // Done
  return octave_value(q);
}
