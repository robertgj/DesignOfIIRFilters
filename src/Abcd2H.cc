// Abcd2H.cc
//
// [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2]= ...
//   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
// Find the complex response and partial derivatives for a state variable
// filter. The outputs are intermediate results in the calculation of
// the squared-magnitude and group-delay responses and partial derivatives.
// For example, for a one-multiplier Schur lattice filter, x may represent
// the concatenated vector [k,c] where k represents the lattice multipliers
// and c represents the tap coefficients. The state variable filter A,B,C
// and D matrixes are assumed to be linear in the x coefficients so that
// the second derivatives d2Adx2,etc are all zero.
//
// Inputs:
//  w         - column vector of angular frequencies   
//  A,B,C,D - state variable description of the lattice filter
//  dAdx,dBdx,dCdx,dDdx - cell vectors of the differentials of A,B,C and D
// Outputs:
//  H - complex vector of the response over w
//  dHdw - complex vector derivative of the complex response wrt w
//  dHdx - complex matrix of the derivative of the response wrt x over w
//  d2Hdwdx - complex matrix of the mixed second derivative wrt w and x over w
//  diagd2Hdx2 - complex matrix of the diagonal of the matrix of second
//               derivatives of the response wrt x over w
//  diagd3Hdwdx2 - complex matrix of the diagonal of the matrix of second
//                 derivatives of the response wrt x and w over w

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

#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(Abcd2H, args, nargout,
"[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2]=\
Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin>9)
      || (nargout>6)
      || ((nargout<=2) && (nargin<5))
      || ((nargout>2) && (nargin<9)))
    {
      print_usage();
    }

  // Input arguments
  ColumnVector w = args(0).column_vector_value();
  ComplexMatrix A = args(1).complex_matrix_value();  
  ComplexColumnVector B = args(2).complex_column_vector_value();
  ComplexRowVector C = args(3).complex_row_vector_value();
  Complex D(args(4).scalar_value(),0);

  // Sanity checks
  if ((A.rows()==0) || (A.columns()==0))
    {
      error("A is empty");
    }
  if (A.rows() != A.columns())
    {
      error("A.rows() != A.columns()");
    }
  if (A.rows() != B.rows())
    {
      error("A.rows() != B.rows()");
    }
  if (A.rows() != C.columns())
    {
      error("A.rows() != C.columns()");
    }

  // Allocate output cell arrays
  Cell dAdx;
  Cell dBdx;
  Cell dCdx;
  Cell dDdx;
  octave_idx_type Nk=A.columns();
  octave_idx_type Nx=0;
  if (nargin==9)
    {
      dAdx=args(5).cell_value();
      dBdx=args(6).cell_value();
      dCdx=args(7).cell_value();
      dDdx=args(8).cell_value();
      Nx=dAdx.numel();
    }
  
  // Outputs
  octave_idx_type Nw=w.numel();
  ComplexColumnVector H(nargout>=1 ? Nw : 0);
  ComplexColumnVector dHdw((nargout>=2 ? Nw : 0));
  ComplexMatrix dHdx((nargout>=3 ? Nw : 0),(nargout>=3 ? Nx : 0));
  ComplexMatrix d2Hdwdx((nargout>=4 ? Nw : 0),(nargout>=4 ? Nx : 0)); 
  ComplexMatrix diagd2Hdx2((nargout>=5 ? Nw : 0),(nargout>=5 ? Nx : 0));
  ComplexMatrix diagd3Hdwdx2((nargout>=6 ? Nw : 0),(nargout>=6 ? Nx : 0));

  // Loop over w
  for (octave_idx_type l=0;l<H.numel();l++)
    {
      // Find the resolvent at w
      Complex expjw(cos(w(l)),sin(w(l)));
      ComplexMatrix zIminusA(-A);
      for(octave_idx_type m=0;m<Nk;m++)
        {
          zIminusA(m,m)+=expjw;
        }
      octave_value_list argval(1),retval(1);
      argval(0)=zIminusA;
      retval=octave::feval("inv",argval,1);
      ComplexMatrix R=retval(0).complex_matrix_value();
      
      // Find H
      ComplexRowVector CR(C*R);
      Complex CRB(CR*B);
      H(l)=CRB+D;
      if (nargout == 1)
        {
          continue;
        }

      // Find dHdw
      ComplexRowVector CRR(CR*R);
      Complex CRRB(CRR*B);
      Complex jexpjw(Complex(0,1)*expjw);
      dHdw(l)=-jexpjw*CRRB;
      if (nargout == 2)
        {
          continue;
        }
      
      // Find dHdx  
      ComplexColumnVector RB(R*B);
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          Complex dDdx_m=dDdx(m).complex_value();
          dHdx(l,m)=(dCdx_m*RB)+(CR*dAdx_m*RB)+(CR*dBdx_m)+dDdx_m;
        }
      if (nargout == 3)
        {
          continue;
        }

      // Find d2Hdwdx 
      ComplexColumnVector RRB(R*RB);
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          d2Hdwdx(l,m)=
            -jexpjw*((CRR*dAdx_m*RB)+(CR*dAdx_m*RRB)+(CRR*dBdx_m)+(dCdx_m*RRB));
        }
      if (nargout == 4)
        {
          continue;
        } 

      // Find diagd2Hdx2 
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          diagd2Hdx2(l,m)=Complex(2,0)*((dCdx_m*R*dAdx_m*RB) +
                                        (dCdx_m*R*dBdx_m) +
                                        (CR*dAdx_m*R*dAdx_m*RB) +
                                        (CR*dAdx_m*R*dBdx_m));
        } 
      if (nargout == 5)
        {
          continue;
        }

      // Find diagd3Hdwdx2
      ComplexMatrix RR(R*R);
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          diagd3Hdwdx2(l,m)=Complex(-2,0)*jexpjw*((CRR*dAdx_m*R*dAdx_m*RB) +
                                                  (CR*dAdx_m*RR*dAdx_m*RB) +
                                                  (CR*dAdx_m*R*dAdx_m*RRB) +
                                                  (dCdx_m*RR*dAdx_m*RB) +
                                                  (dCdx_m*R*dAdx_m*RRB) +
                                                  (CRR*dAdx_m*R*dBdx_m) +
                                                  (CR*dAdx_m*RR*dBdx_m) +
                                                  (dCdx_m*RR*dBdx_m));
        } 
    }

  // Done
  octave_value_list retval(nargout);
  if (nargout >= 1)
    {
      retval(0)=H;
    }
  if (nargout >= 2)
    {
      retval(1)=dHdw;
    }
  if (nargout >= 3)
    {
      retval(2)=dHdx;
    }
  if (nargout >= 4)
    {
      retval(3)=d2Hdwdx;
    }
  if (nargout >= 5)
    {
      retval(4)=diagd2Hdx2;
    }
  if (nargout == 6)
    {
      retval(5)=diagd3Hdwdx2;
    }
  return retval;
}
