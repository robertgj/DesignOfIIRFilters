// schurNSscale.cc
//
// Implement scaling for the "top" row of Parhi's Schur lattice filter having
// normalised scaled lattice coefficients with the MPFR arbitrary precision 
// floating-point library.
//
// Compile with:
//   mkoctfile -lgmp -lmpfr schurNSscale.cc
//
// Octave function file schurNSscale.m shows the original Octave code.
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

#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(schurNSscale, args, nargout,
          "[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)")
{
  if ((args.length() != 2) || (nargout != 6))
    {
      print_usage();
      return octave_value_list();
    }
  if (args(1).length() == 0)
    {
      error("c is empty");
      return octave_value_list();
    }
  if ((args(0).length()+1) != args(1).length())
    {
      error("(length(k)+1) ~= length(c)");
      return octave_value_list();
    }

  // Set precision to use
  mpfr_prec_t prec = 256;

  // Input arguments
  uint64_t N = args(0).length();
  RowVector k = args(0).vector_value();
  RowVector c = args(1).vector_value();

  // Simple case
  if (N==0)
    {
      octave_value_list retval(6);
      retval(0)=c(0);
      retval(1)=0;
      retval(2)=1;
      retval(3)=0;
      retval(4)=-1;
      retval(5)=0;
      return octave_value_list(retval);
    }
  
  // s10 and s11 outputs
  RowVector s10(N);
  RowVector s11(N);

  // Allocate and initialise mpfr
  mpfr_t mtmp;
  mpfr_t mcc[N+1];
  mpfr_init2(mtmp, prec);
  for (uint64_t l=0;l<N+1;l++)
    {
      mpfr_init2(mcc[l],prec);
    }

  // Cumulative sum of squared expansion coefficients (for scaling)
  // Octave :  cc=sqrt(cumsum(c.^2))
  mpfr_set_d(mcc[0], c(0), MPFR_RNDN);
  mpfr_mul(mcc[0], mcc[0], mcc[0], MPFR_RNDN);
  for (uint64_t l=1;l<N+1;l++)
    {
      mpfr_set_d(mcc[l], c(l), MPFR_RNDN);
      mpfr_mul(mcc[l], mcc[l], mcc[l], MPFR_RNDN);
      mpfr_add(mcc[l], mcc[l], mcc[l-1], MPFR_RNDN);  
    }
  for (uint64_t l=0;l<N+1;l++)
    {
      mpfr_sqrt(mcc[l], mcc[l], MPFR_RNDN); 
    }

  // Synthesise scaled coefficients of the lattice filter
  // Octave : s10=[c(2:N)./cc(2:N) c(N+1)]
  for (uint64_t l=0;l<N-1;l++)
    {
      mpfr_set_d(mtmp, c(l+1), MPFR_RNDN);
      mpfr_div(mtmp, mtmp, mcc[l+1], MPFR_RNDN);
      s10(l) = mpfr_get_d(mtmp, MPFR_RNDN);
    }
  s10(N-1)=c(N);
  // Octave : s11=[cc(1:(N-1))./cc(2:N) cc(N)]
  for (uint64_t l=0;l<N-1;l++)
    {
      mpfr_div(mtmp, mcc[l], mcc[l+1], MPFR_RNDN);
      s11(l) = mpfr_get_d(mtmp, MPFR_RNDN);
    }
  s11(N-1)=mpfr_get_d(mcc[N-1], MPFR_RNDN);
  // Octave : s11(1)=s11(1)*sign(c(1))
  s11(0)=s11(0)*((c(0)<0) ? -1 : 1);

  // s20, s00, s02, s22
  RowVector s20(N);
  RowVector s00(N);
  RowVector s02(N);
  RowVector s22(N);
  mpfr_t msqrt1_k2;
  mpfr_init2(msqrt1_k2, prec);
  for (uint64_t l=0;l<N;l++)
    {
      s20(l) = k(l);
      s02(l) = -k(l);
      mpfr_set_d(msqrt1_k2, k(l), MPFR_RNDN);
      mpfr_mul(msqrt1_k2, msqrt1_k2, msqrt1_k2, MPFR_RNDN);
      mpfr_d_sub(msqrt1_k2, 1.0, msqrt1_k2, MPFR_RNDN);
      mpfr_sqrt(msqrt1_k2, msqrt1_k2, MPFR_RNDN);
      s00(l) = mpfr_get_d(msqrt1_k2, MPFR_RNDN); 
      s22(l) = mpfr_get_d(msqrt1_k2, MPFR_RNDN); 
    }

  // Cleanup
  mpfr_clear(mtmp);      
  for (uint64_t l=0;l<N+1;l++)
    {
      mpfr_clear(mcc[l]);
    }
  mpfr_clear(msqrt1_k2);      

  // Done
  octave_value_list retval(6);
  retval(0)=s10;
  retval(1)=s11;
  retval(2)=s20;
  retval(3)=s00;
  retval(4)=s02;
  retval(5)=s22;
  return octave_value_list(retval);
}
