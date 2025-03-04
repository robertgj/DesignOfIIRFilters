// bin2SD.cc
//
// y=bin2SD(x,nbits,ndigits)
// Convert an nbits 2's complement binary number x with digits from {0,1} in
// the range -2^(nbits-1) <= x <= 2^(nbits-1) to a number equivalent to the
// signed-digit number with nbits ternary digits from {-1,0,1} of which
// ndigits are non-zero.

// Compile with:
//   mkoctfile -Wall bin2SD.cc


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
#include <math.h>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(bin2SD, args, nargout, "y=bin2SD(x,nbits,ndigits)")
{
  if (args.length() != 3)
    {
      print_usage();
      return octave_value_list();
    }

  // Do this once!
  static bool bit_max_init_done=false;
  static int64_t max_nbits=0;
  if (bit_max_init_done==false)
    {
      octave_value_list flintmax_retval = octave::feval("flintmax");
      double bit_max = flintmax_retval(0).double_value(true);
      max_nbits = floor(log2(bit_max)-2);
      bit_max_init_done=true;
    }

  // Sanity check on nbits
  const int64_t nbits = args(1).int64_value(true);
  if ((nbits<=0) ||(nbits>max_nbits))
    {
      error("Expected 0<nbits(%ld)<=%ld",nbits,max_nbits);
      return octave_value_list();
    }

  // Sanity check on ndigits
  int64_t ndigits = nbits;
  if (args.length() >= 3)
    {
      ndigits = args(2).int64_value(true);
      if (ndigits == 0)
        {
          // SD allocation may allocate 0 signed digits
          octave_value_list retval(1);
          retval(0)=0;
          return retval;
        }
      else if ((ndigits<0) || (ndigits>nbits))
        {
          error("Expected 0<=ndigits(%ld)<=nbits(%ld)",ndigits,nbits);
          return octave_value_list();
        }
    }
  
  // Sanity check on x
  if (args(0).length() != 1)
    {
      error("x is not a scalar");
      return octave_value_list();
    }
  double x = args(0).double_value(true);
  double nscale = round(ldexp(1,nbits-1));
  if ((round(x)<-nscale) || (nscale<=round(x)))
    {
      error
        ("x=%g,round(x)=%g is out of range for a %ld bits 2s complement number!",
         x,round(x),nbits);
      return octave_value_list();
    }

  // Find the signed-digit equivalent
  int64_t y=0;
  for (int64_t k=0,nd=0,xx=round(x),r=nscale*((xx>=0)?(1):(-1)); k<nbits; k++)
    {
      if ((nd >= ndigits) || (xx == 0))
        {
          break;
        }
      else if (labs(4*xx) >= labs(3*r))
        {
          xx=xx-r;
          y=y+r;
          nd=nd+1;
        }
      else if (labs(2*xx) >= labs(r))
        {
          xx=xx-(r/2);
          y=y+(r/2);
          nd=nd+1;
        }
      r=(labs(r)/2)*((xx>=0)?(1):(-1));
    }

  // Done
  octave_value_list retval(1);
  retval(0)=y;
  return retval;
}
