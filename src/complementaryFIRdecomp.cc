// complementaryFIRdecomp.cc
//
// Implement the complementary recursion for degree reduction of an FIR
// polynomial and calculation of the FIR lattice coefficients
// with the MPFR arbitrary precision floating-point library.
//
// Compile with:
//   mkoctfile -lgmp -lmpfr complementaryFIRdecomp.cc
//
// Octave function file complementaryFIRdecomp.m shows the original Octave code.
//
// See: "Passive Cascaded-Lattice Structures for Low-Sensitivity FIR
// Filter Design, with Applications to Filter Banks",
// P. P. Vaidyanathan, IEEE Transactions on Circuits and Systems,
// Vol. 33, No. 11, pp 1045-1064, November 1986.


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

#include <limits>
#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(complementaryFIRdecomp, args, nargout,
          "[k,khat]=complementaryFIRdecomp(g,h[,tol])")
{
  // Sanity checks
  if ((args.length() != 2) && (args.length() != 3))
    {
      print_usage();
      return octave_value_list();
    }
  if (args(0).length() != args(1).length())
    {
      error("Expect length(h)==length(g)!");
      return octave_value_list();
    }
  
  // Input arguments
  uint64_t N = args(0).length();
  ColumnVector h = args(0).vector_value();
  ColumnVector g = args(1).vector_value();
  double tol;
  double eps = std::numeric_limits<double>::epsilon ();
  if (args.length() == 2)
    {
      tol = 10*eps;
    }
  else
    {
      tol = args(2).double_value(true);
    }
  
  // Temporary output storage
  ColumnVector tmpk(N);
  ColumnVector tmpkhat(N);

  // Set precision to use
  mpfr_prec_t prec = 1024;

  // Allocate and initialise mpfr
  mpfr_t tmp;
  mpfr_init2(tmp, prec);
  mpfr_set_d(tmp, 0, MPFR_RNDN);

  mpfr_t kn;
  mpfr_init2(kn, prec);
  mpfr_set_d(kn, 0, MPFR_RNDN);

  mpfr_t khatn;
  mpfr_init2(khatn, prec);
  mpfr_set_d(khatn, 0, MPFR_RNDN);
  
  mpfr_t hm[N];
  for (uint64_t n=0;n<N;n++)
    {
      mpfr_init2(hm[n],prec);
      mpfr_set_d(hm[n], h(n), MPFR_RNDN);
    }

  mpfr_t hmtmp[N];
  for (uint64_t n=0;n<N;n++)
    {
      mpfr_init2(hmtmp[n],prec);
      mpfr_set_d(hmtmp[n], 0, MPFR_RNDN);
    }

  mpfr_t gm[N];
  for (uint64_t n=0;n<N;n++)
    {
      mpfr_init2(gm[n],prec);
      mpfr_set_d(gm[n], g(n), MPFR_RNDN);
    }

  // Downward recursion for FIR polynomial order reduction
  uint64_t Nknz=0;
  for (uint64_t n=N-1;;n--)
    {
      if ((mpfr_cmp_d(hm[n],0.0) == 0) && (mpfr_cmp_d(gm[n],0.0) == 0))
        {
          // No order reduction step
          fprintf(stderr,"Nknz=%lu: hm[%lu] == gm[%lu] == 0\n",Nknz,n,n);
          continue;
        }

      // Lattice coefficients. Use Equation 23 as 13 and 14 accumulate errors
      mpfr_hypot(tmp, hm[0], gm[0], MPFR_RNDN);
      mpfr_div(kn,    hm[0], tmp, MPFR_RNDN);
      mpfr_div(khatn, gm[0], tmp, MPFR_RNDN);
          
      // Length of k and khat may be less than that of h and g
      tmpk(Nknz)=mpfr_get_d(kn, MPFR_RNDN);
      tmpkhat(Nknz)=mpfr_get_d(khatn, MPFR_RNDN);
      Nknz=Nknz+1;
      if (n == 0)
        {
          break;
        }
                
      // New polynomials
      for (uint64_t m=0;m<=n;m++)
        {
          mpfr_mul(hmtmp[m],    hm[m],    kn, MPFR_RNDN);
          mpfr_mul(     tmp,    gm[m], khatn, MPFR_RNDN);
          mpfr_add(hmtmp[m], hmtmp[m],   tmp, MPFR_RNDN);
          
          mpfr_mul(   gm[m],    gm[m],    kn, MPFR_RNDN);
          mpfr_mul(     tmp,    hm[m], khatn, MPFR_RNDN);
          mpfr_sub(   gm[m],    gm[m],   tmp, MPFR_RNDN);
        }

      // Sanity checks
      mpfr_set(tmp, hmtmp[n], MPFR_RNDN);
      mpfr_abs(tmp, tmp, MPFR_RNDN);
      if (mpfr_cmp_d(tmp, tol) > 0)
        {
          error("Expected abs(hmtmp[n]) (=%g) <= tol !",
                mpfr_get_d(tmp, MPFR_RNDN));
          goto done;
        }
      mpfr_set(tmp, gm[0], MPFR_RNDN);
      mpfr_abs(tmp, tmp, MPFR_RNDN);
      if (mpfr_cmp_d(tmp, tol) > 0)
        {
          error("Expected abs(gm[0]) (=%g) <= tol !",
                mpfr_get_d(tmp, MPFR_RNDN));
          goto done;
        }

      // Order reduction
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_set(gm[m], gm[m+1], MPFR_RNDN);
          mpfr_set(hm[m], hmtmp[m], MPFR_RNDN);
        }

      // Sanity check. Use hm[N-1] and gm[N-1] for temporary storage.
      mpfr_set_d(tmp, 0, MPFR_RNDN);
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_mul(hm[N-1], hm[m], hm[m], MPFR_RNDN);
          mpfr_mul(gm[N-1], gm[m], gm[m], MPFR_RNDN);
          mpfr_add(tmp, tmp, hm[N-1], MPFR_RNDN);
          mpfr_add(tmp, tmp, gm[N-1], MPFR_RNDN);
        }
      mpfr_sub_d(tmp, tmp, 1.0, MPFR_RNDN);
      mpfr_abs(tmp, tmp, MPFR_RNDN);
      if (mpfr_cmp_d(tmp, tol) > 0)
        {
          error("Expected abs(hm'*hm + gm'*gm - 1) (%g*eps) < tol(%g*eps)!",
                mpfr_get_d(tmp, MPFR_RNDN)/eps,tol/eps);
          goto done;
        }
      
    }

  // Done
 done:    
  
  // Cleanup
  mpfr_clear(tmp);
  mpfr_clear(kn);
  mpfr_clear(khatn);
  for (uint64_t l=0;l<N;l++)
    {
      mpfr_clear(hm[l]);
      mpfr_clear(hmtmp[l]);
      mpfr_clear(gm[l]);
    }

  // Output arguments
  ColumnVector k(Nknz);
  ColumnVector khat(Nknz);
  for (uint64_t l=0;l<Nknz;l++)
    {
      k(Nknz-l-1) = tmpk(l);
      khat(Nknz-l-1) = tmpkhat(l);
    }

  // Set return values
  octave_value_list retval(2);
  retval(0)=k;
  retval(1)=khat;
  return octave_value_list(retval);
}
