// minphase.cc
//
// [y,ssp,iter] = minphase(h)
// C++ implementation of minphase.m with the Eigen C++ template library:
//   m-file for extracting the minimum phase factor from the 
//   linear-phase filter h. Input: h = (h(0) h(1)...h(N)] (row vector) 
//   where the h vector is the right half of a linear-phase FIR filter.
//   It is presumed that any unit-circle zeros of h are of even multiplicity. 
//   Copyright (c) January 2002  by  H. J. Orchard and A. N. Willson, Jr.

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

#include <cfloat>
#include <Eigen/Eigen>
#include <octave/oct.h>
#include <octave/parse.h>

typedef Eigen::Matrix<long double,Eigen::Dynamic,1> EigenVectorNx1ld;
typedef Eigen::Matrix<long double,Eigen::Dynamic,Eigen::Dynamic>
  EigenMatrixNxNld;

DEFUN_DLD(minphase, args, nargout,"[y,ssp,iter] = minphase(h)")
{

  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin>1) || (nargout>3))
    {
      print_usage();
    }

  // Input arguments
  ColumnVector h = args(0).column_vector_value();
  octave_idx_type N=h.numel();
    
  // Output arguments
  RowVector y(N);
  long double ssp = LDBL_MAX;
  octave_idx_type iter = 0;
  
  // Initialise ss
  long double ss=ssp/2;

  // Initialise column vector hh
  EigenVectorNx1ld hh(N);
  for(auto r=0;r<N;r++)
    {
      hh(r)=h(r);
    }
  
  // Initialise column vectors yy, b and d
  EigenVectorNx1ld yy(N);
  EigenVectorNx1ld d(N);
  EigenVectorNx1ld b(N);
  for (auto r=0;r<N;r++)
    {
      yy(r)=0;
      d(r)=0;
    }
  yy(0)=1;
  
  // Allocate A, Al and Ar
  EigenMatrixNxNld A(N,N);
  EigenMatrixNxNld Al(N,N);
  EigenMatrixNxNld Ar(N,N);
  
  for (auto r=0;r<N;r++)
    {
      for (auto c=0;c<N;c++)
        {   
          A(r,c)=0;
          Al(r,c)=0;
          Ar(r,c)=0;
        }
    }

  // Newton-Raphson iteration
  while (ss < ssp)
    {
      yy=yy+d;
      ssp=ss;
      iter=iter+1;
      
      for(auto r=0;r<N;r++)
        {
          for (auto c=r;c<N;c++)
            {   
              Al(r,c-r)=yy(c);
            }
          for (auto c=0;c<(N-r);c++)
            {   
              Ar(r,c+r)=yy(c);
            }
        }
      A=Al+Ar;
      b=hh-(Al*yy);
      d=A.colPivHouseholderQr().solve(b);
      ss=d.norm();
    }

  // Done
  for(auto r=0;r<N;r++)
    {
      y(r)=(double)(yy(r));
    }
  octave_value_list retval(nargout);
  if (nargout >= 1)
    {
      retval(0)=y;
    }
  if (nargout >= 2)
    {
      retval(1)=(double)ssp;
    }
  if (nargout == 3)
    {
      retval(2)=iter;
    }
  return retval;
}
