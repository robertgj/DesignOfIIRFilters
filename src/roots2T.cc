// roots2T.cc - given the all real roots of a polynomial, find the
// coefficients of the expansion of the polynomial in Chebyshev
// polynomials of the first kind

// Copyright (C) 2019 Robert G. Jenssen
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

#include <stdlib.h>
#include <stdio.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(roots2T, args, nargout, "a=roots2T(r)")
{

  // Sanity checks
  auto nargin=args.length();
  if ((nargin!=1) || (nargout>1))
    {
      print_usage();
    }

  // Input argument
  RowVector r = args(0).row_vector_value();
  auto N=r.numel();

  if (N==0)
    {
      RowVector a(0);
      octave_value_list retval(1);
      retval(0)=a;
      return octave_value_list(retval);
    }

  if (N==1)
    {
      RowVector a(2);
      a(0)=-r(0);
      a(1)=1;
      octave_value_list retval(1);
      retval(0)=a;
      return octave_value_list(retval);
    }
  
  // Set precision
  mpfr_prec_t prec = 4096;

  // Allocate
  const double scale=1;
  mpfr_t ma[N+1];
  mpfr_t mlasta[N+1];

  // Initialise   
  for (auto l=0;l<=N;l++)
    {
      mpfr_init2(ma[l], prec);
      mpfr_set_d(ma[l], 0, MPFR_RNDN);
      mpfr_init2(mlasta[l], prec);
      mpfr_set_d(mlasta[l], 0, MPFR_RNDN);
    }
  
  // lasta[0]=-r(0);
  mpfr_set_d(mlasta[0], -r(0), MPFR_RNDN);

  // lasta[1]=1;
  mpfr_set_d(mlasta[1], 1, MPFR_RNDN);

  // Loop
  for (auto m=1;m<=(N-1);m++)
    {
      // lasta[m+1]=0
      mpfr_set_d(mlasta[m+1], 0, MPFR_RNDN);
      
      // a[0]=(lasta[1]-(2*r[m]*lasta[0]))/scale;
      mpfr_mul_d(ma[0], mlasta[0],  r(m), MPFR_RNDN);
      mpfr_mul_d(ma[0], ma[0],         2, MPFR_RNDN);
      mpfr_sub  (ma[0], mlasta[1], ma[0], MPFR_RNDN); 
      mpfr_div_d(ma[0], ma[0],     scale, MPFR_RNDN);
              
      // a[1]=(lasta[2]+(2*lasta[0])-(2*r[m]*lasta[1]))/scale;
      mpfr_mul_d(ma[1], mlasta[1],      r(m), MPFR_RNDN);
      mpfr_sub  (ma[1], mlasta[0],     ma[1], MPFR_RNDN); 
      mpfr_mul_d(ma[1],     ma[1],         2, MPFR_RNDN); 
      mpfr_add  (ma[1],     ma[1], mlasta[2], MPFR_RNDN); 
      mpfr_div_d(ma[1],     ma[1],     scale, MPFR_RNDN);
      
      for(auto l=2;l<=m;l++)
        {
          // a[l]=(lasta[l-1]+lasta[l+1]-(2*r[m]*lasta[l]))/scale;
          mpfr_mul_d(ma[l],   mlasta[l],  r(m), MPFR_RNDN);
          mpfr_mul_d(ma[l],       ma[l],     2, MPFR_RNDN);
          mpfr_sub  (ma[l], mlasta[l+1], ma[l], MPFR_RNDN); 
          mpfr_add  (ma[l], mlasta[l-1], ma[l], MPFR_RNDN); 
          mpfr_div_d(ma[l],       ma[l], scale, MPFR_RNDN);
        }
      
      // a[m+1]=lasta[m]/scale;
      mpfr_div_d(ma[m+1], mlasta[m], scale, MPFR_RNDN);
      
      for(auto l=0;l<=(m+1);l++)
        {
          // lasta[col]=a[col];
          mpfr_set(mlasta[l], ma[l], MPFR_RNDN);
        }
    }

  // Copy output
  RowVector a(N+1);
  for (auto l=0;l<=N;l++)
    {
      a(l) = mpfr_get_d(ma[l], MPFR_RNDN);
    }

  // Deallocate
  for (auto l=0;l<=N;l++)
    {
      mpfr_clear(ma[l]);
      mpfr_clear(mlasta[l]);
    }

  // Done
  return octave_value(a);
}

