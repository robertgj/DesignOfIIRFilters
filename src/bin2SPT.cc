// bin2SPT.cc
//
// spt=bin2SPT(x,nbits)
// Convert an nbits 2's complement binary number x with digits from
// {0,1} in the range -2^(nbits-1) <= x <= 2^(nbits-1) to a
// signed-digit number with nbits ternary digits from {-1,0,1}.
//
// See Section 13.6.1 of the book "VLSI Digital Signal Processing 
// Systems: Design and Implementation" by Keshab K. Parhi. 
//
// The algorithm used to convert a W-bit 2's complement number
// AHat=aHat(W-1)aHat(W-2)---aHat(1)aHat(0) to a W-bit CSD number
// A=a(W-1)a(W-2)---a(1)a(0) is:
//
//   aHat(-1)=0
//   aHat(W)=aHat(W-1)
//   gamma(-1)=0
//   for i=0:(W-1)
//     theta=aHat(i) ^ aHat(i-1)
//     gamma(i)=(~gamma(i-1))*theta
//     a(i)=(1-2*aHat(i+1))*gamma(i)
//   endfor
//
// where "^" means exclusive-or and "~" means ones-complement.
//
// The signed-digit representation produced by this algorithm is said
// to be "canonical":
//  - each digit is a number in the set {-1,0,1}
//  - no two consecutive bits are nonzero
//  - the representation contains the minimum number of nonzero bits
//  - the representation is unique
//
// Example 13.6.1 of the reference shows conversion of 101110011 or
// -bin2dec("010001101") or -141 to {0,-1,0,0,-1,0,1,0,-1}
// where the left-most digit is the MSD and represents {-256,0,256}.
//
// The Octave function file bin2SPT.m shows the original Octave code.
// The Octave profiler showed that the bitget() etc functions are slow.

// Compile with:
//   mkoctfile -Wall bin2SPT.cc
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
#include <math.h>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(bin2SPT,args,nargout,"spt=bin2SPT(x,nbits)")
{
  if ((args.length()>2) || (nargout>1))
    {
      print_usage();
      return octave_value_list();
    }

  // Sanity check on x
  if (args(0).length() != 1)
    {
      error("x is not a scalar");
      return octave_value_list();
    }
  double x = args(0).double_value(true);
  int64_t xx = round(x);
  
  // Sanity checks on nbits
  octave_idx_type nbits;
  if (args.length()==1)
    {
      if (xx==0)
        {
          nbits=1;
        }
      else
        {
          nbits=1+ceil(log2(abs(xx)));
        }
    }
  else
    {
      nbits=args(1).int64_value(true);
    }
  if (nbits<=0)
    {
      error("nbits<=0");
      return octave_value_list();
    }

  // Do this once!
  static bool bit_max_init_done=false;
  static octave_idx_type max_nbits=0;
  if (bit_max_init_done==false)
    {
      octave_value_list flintmax_retval = feval("flintmax");
      double bit_max = flintmax_retval(0).double_value(true);
      max_nbits = floor(log2(bit_max)-2);
      bit_max_init_done=true;
    }
  // Check size of nbits
  if ((nbits<=0) ||(nbits>max_nbits))
    {
      error("Expected 0<nbits(%d)<=%d",nbits,max_nbits);
      return octave_value_list();
    }

  // Initialise outputs
  RowVector spt(nbits);
  for (octave_idx_type n=0;n<nbits;n++)
    {
      spt(n)=0;
    }
  
  // Handle -0.5<x<0.5
  if (xx==0)
    {
      octave_value_list retval(1);
      retval(0)=spt;
      return retval;
    }

  // Check abs(round(x)) that is in range
  double log2xx=log2(abs(xx));
  if (log2xx>(nbits-1))
    {   
      error("round(x)=%ld is out of range for a %d bits signed-digit number",
            xx,nbits);
      return octave_value_list();
    }

  // Handle abs(round(x)) is a power of 2
  double power_of_2;
  if (modf(log2xx,&power_of_2)==0)
    {
      if (xx>0)
        {
          spt(power_of_2)=1;
        }
      else
        {
          spt(power_of_2)=-1;
        }
      octave_value_list retval(1);
      retval(0)=spt;
      return retval;
    }
  
  // Find the nbits 2's complement representation of round(x)
  int64_t nbits_mask=(1L<<nbits)-1;
  xx=xx&nbits_mask;
  
  // Find the canonical signed-digit representation
  int64_t xxw=((xx&(1L<<(nbits-1)))<<1) | xx; // Duplicate the sign bit
  int64_t ahat_km1 = 0;
  int64_t gamma_km1 = 0;
  for (int64_t k=0; k<nbits; k++)
    {
      int64_t ahat_k = xxw&1;
      int64_t ahat_kp1x2 = xxw&2;
      int64_t theta = (ahat_k^ahat_km1)&1;
      int64_t gamma_k = (~gamma_km1)&theta;
      spt(k) = (1-ahat_kp1x2)*gamma_k;
      ahat_km1 = ahat_k;
      gamma_km1 = gamma_k;
      xxw = xxw>>1;
    }

  // Done
  octave_value_list retval(1);
  retval(0)=spt;
  return retval;
}
