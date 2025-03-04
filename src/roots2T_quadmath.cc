// roots2T_quadmath.cc - given the all real roots of a polynomial, find the
// coefficients of the expansion of that polynomial in Chebyshev polynomials
// of the first kind with quad float arithmetic.
// Compile with:
//  XCXXFLAGS="-lquadmath -fext-numeric-literals" make src/roots2T_quadmath.oct

// Copyright (C) 2019-2025 Robert G. Jenssen
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

#include <quadmath.h>
#include <stdlib.h>
#include <stdio.h>
#include <octave/oct.h>

DEFUN_DLD(roots2T_quadmath, args, nargout, "a=roots2T_quadmath(r)")
{

  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin!=1) || (nargout>1))
    {
      print_usage();
    }

  // Input arguments
  RowVector rarg = args(0).row_vector_value();
  octave_idx_type N=rarg.numel();
  if (N==0)
    {
      RowVector aarg(0);
      octave_value_list retval(1);
      retval(0)=aarg;
      return octave_value_list(retval);
    }

  if (N==1)
    {
      RowVector aarg(2);
      aarg(0)=-rarg(0);
      aarg(1)=1;
      octave_value_list retval(1);
      retval(0)=aarg;
      return octave_value_list(retval);
    }
  
  // Initialise arguments
  __float128 r[N];
  memset(r, 0, N*sizeof(__float128));
  for(octave_idx_type col=0;col<N;col++)
    {
      r[col]=rarg(col);
      if (0)
        {
          int width = 36;
          char bufr[128];
          quadmath_snprintf(bufr, sizeof(bufr),"%+-#*.30Qf",width,r[col]);
          fprintf(stderr,"r[%ld]=%s\n",col,bufr);
        }
    }
  __float128 a[N+1];
  __float128 lasta[N+1];
  for(octave_idx_type col=0;col<=N;col++)
    {
      a[col]=0;
      lasta[col]=0;
    }

  const int scale=1;
  lasta[0]=-r[0];
  lasta[1]=1;
  for (octave_idx_type m=1;m<=(N-1);m++)
    {
      lasta[m+1]=0;
      a[0]=(lasta[1]-(2*r[m]*lasta[0]))/scale;
      a[1]=(lasta[2]+(2*lasta[0])-(2*r[m]*lasta[1]))/scale;
      for(octave_idx_type l=2;l<=m;l++)
        {
          a[l]=(lasta[l-1]+lasta[l+1]-(2*r[m]*lasta[l]))/scale;
        }
      a[m+1]=lasta[m]/scale;
      for(octave_idx_type col=0;col<=(m+1);col++)
        {
          lasta[col]=a[col];
        }
    }

  // Done
  RowVector aarg(N+1);
  for(octave_idx_type col=0;col<=N;col++)
    {
      aarg(col)=a[col];
    }
  octave_value_list retval(1);
  retval(0)=aarg;

  return retval;
}

