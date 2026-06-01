// schurOneMlatticeFilter.cc
//
// [yap y xx] = schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)
// Simulate a Schur one-multiplier lattice filter.
// Inputs:
//  k        - the lattice filter one-multiplier coefficients (used as 1:Nk)
//  epsilon  - the sign coefficients for each module (used as 1:Nk)
//  p        - the state scaling factors (used as 0:(Nk-1))
//  c        - the numerator polynomial orthogonal basis weights (used as 0:Nk)
//  u        - input sequence (Nu)
//  rounding - rounding mode. "round" for rounding to nearest
//             and "fix" for truncation to zero(2s complement)
// Outputs:  
//  yap - all pass output (Nu)
//  y   - filter output (Nu)
//  xx  - state (Nu+1 by 0:(Nk-1))
//
// See DesignOfSchurLatticeFIlters.tex
//
// To debug with gdb:
/*
   XCXXFLAGS="-ggdb3 -O0" make -B schurOneMlatticeFilter.oct
   gdb -ex "b FschurOneMlatticeFilter" \
       --args octave --no-gui -p src src/test/schurOneMlatticeFilter_test.m
*/
// To run address-sanitizer:
/*
   XCXXFLAGS="-ggdb3 -O0 -fsanitize=undefined -fsanitize=address \
              -fno-sanitize=vptr -fno-omit-frame-pointer" \
   make -B schurOneMlatticeFilter.oct
   LD_PRELOAD=/usr/lib64/libasan.so.8 \
   octave --no-gui -p src -p src/test --eval "schurOneMlatticeFilter_test"
*/

// Copyright (C) 2025 Robert G. Jenssen
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

#include <cstring>
#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

static double no_rounding(double x) { return x; }

DEFUN_DLD(schurOneMlatticeFilter, args, nargout,
          "[yap y xx] = schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin != 6) || (nargout>3))
    {
      print_usage();
      return octave_value_list();
     }

  if (nargout == 0)
    {
      return octave_value_list();
    }

  // Input arguments
  octave_idx_type Nk=args(0).numel();
  RowVector arg0=args(0).row_vector_value();
  RowVector k(Nk+1);
  k(0) = 0.0;
  for (octave_idx_type n=1;n<=arg0.numel();n++)
    {
      k(n)=arg0(n-1);
    }

  RowVector arg1 = args(1).row_vector_value();
  if (arg1.numel() != Nk)
    {
      error("k and epsilon vector lengths inconsistent!");
      return octave_value_list();
    }
  RowVector epsilon(Nk+1);
  epsilon(0) = 0.0;
  for (octave_idx_type n=1;n<=arg1.numel();n++)
    {
      epsilon(n)=arg1(n-1);
    }

  RowVector arg2 = args(2).row_vector_value();
  if (arg2.numel() != Nk)
    {
      error("k and p vector lengths inconsistent!");
      return octave_value_list();
    }
  RowVector p(Nk);
  for (octave_idx_type n=0;n<arg2.numel();n++)
    {
      p(n)=arg2(n);
    }

  RowVector c = args(3).row_vector_value();
  if (c.numel() != (Nk+1))
    {   
      error("k and c vector lengths inconsistent!");
      return octave_value_list();
    }
  
  ColumnVector u = args(4).column_vector_value();
  octave_idx_type Nu=u.numel();
  if (Nu == 0)
    {
      return octave_value_list();
    }

  double (*fround)(double x);
  try
    {
      charMatrix ch = args(5).char_matrix_value ();
      std::string rounding = ch.row_as_string(0);
      if (rounding.compare(0, 3, std::string("non")) == 0) 
        {
          fround = &no_rounding;
        }
      else if (rounding.compare(0, 3, std::string("rou")) == 0)
        {
          fround = &round;
        }
      else if (rounding.compare(0, 3, std::string("fix")) == 0)
        {
          fround = &trunc;
        }
      else
        {
          error("Expect rounding to be \"none\", \"round\" or \"fix\"!");
          return octave_value_list();
        }
    }
  catch(...)
    {
      error("rounding string error!");
      return octave_value_list();
    }
  
  //
  // Run the filter
  //
  ColumnVector yap(Nu);
  ColumnVector y(Nu);
  Matrix xx(Nu+1,Nk);

  RowVector x(Nk);
  RowVector yhat(Nk);
  RowVector xprime(Nk);
  for (octave_idx_type n=0;n<Nk;n++)
    {
      x(n) = 0.0;
      yhat(n) = 0.0;
      xprime(n) = 0.0;
      xx(0,n) = 0.0;
    }
  
  for (octave_idx_type m=0;m<Nu;m++)
    {
      // State scaling
      for (octave_idx_type n=0;n<Nk;n++)
        {
          x(n)=x(n)*p(n);
        }

      // Filter
      yhat(0)=x(0);
      for (octave_idx_type n=1;n<Nk;n++)
        {
          // Lattice section
          xprime(n-1) = (-k(n)*yhat(n-1))+
                        ((1.0+(k(n)*epsilon(n)))*x(n));
          yhat(n) = ((1-(k(n)*epsilon(n)))*yhat(n-1))+(k(n)*x(n));

          // Round all pass intermediate output
          yhat(n) = p(n)*fround(yhat(n)/p(n));
        }
      
      // Output lattice section
      xprime(Nk-1) = (-k(Nk)*yhat(Nk-1))+((1+(k(Nk)*epsilon(Nk)))*u(m));
      yap(m) = ((1-(k(Nk)*epsilon(Nk)))*yhat(Nk-1))+(k(Nk)*u(m));
      yap(m) = fround(yap(m));

      // Tapped output
      y(m) = 0.0;
      for (octave_idx_type n=0;n<Nk;n++)
        {
          y(m) = y(m)+(c(n)*x(n));
        }
      y(m) = y(m)+(c(Nk)*u(m));
      y(m) = fround(y(m));
       
      // Update and save state
      for(octave_idx_type n=0;n<Nk;n++)
        {
          x(n) = fround(xprime(n)/p(n));
          xx(m+1,n) = x(n);
        }
    }
  
  // Done
  octave_value_list retval(nargout);
  if (nargout >= 1)
    {
      retval(0)=yap;
    }
  if (nargout >= 2)
    {
      retval(1)=y;
    }
  if (nargout >= 3)
    {
      retval(2)=xx;
    }

  return retval;
}
