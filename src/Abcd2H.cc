// Abcd2H.cc
//
// H=Abcd2H(w,A,B,C,D)
// [H,dHdw] = Abcd2H(w,A,B,C,D)
// [H,dHdw,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
// [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
// [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2] =
//   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
// [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] =
//   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
// [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx] = 
//   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
// [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx]= ...
//   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
//
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
//  w - column vector of angular frequencies   
//  A,B,C,D - state variable description of the lattice filter
//  dAdx,dBdx,dCdx,dDdx - cell vectors of the differentials of A,B,C and D
//  d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx - cell arrays of the 2nd derivatives of
//                                    A,B,C and D wrt coefficients x and y
// Outputs:
//  H - complex vector of the response over w
//  dHdw - complex vector derivative of the complex response wrt w
//  dHdx - complex matrix of the derivative of the response wrt x over w
//  d2Hdwdx - complex matrix of the mixed second derivative wrt w and x over w
//  diagd2Hdx2 - complex matrix of the diagonal of the matrix of second
//               derivatives of the response wrt x over w
//  diagd3Hdwdx2 - complex matrix of the diagonal of the matrix of second
//                 derivatives of the response wrt x over w 
//  d2Hdydx - the Hessian matrix of the response wrt the coefficients
//  d3Hdwdydx - the Hessian matrix of the response wrt the coefficients over w
//
// In the following, confusingly, Nx is the number of filter coefficients
// (eg: k and c) and Nk is the number of filter states.
//
// For each output other than d2Hdydx, the rows correspond to frequency
// vector, w, of length Nw and the columns correspond to the coefficient
// vector, x, of length Nx. d2Hdydx is returned as a matrix of size (Nw,Nx,Nx).

// Copyright (C) 2017-2024 Robert G. Jenssen
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
"[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx]=\
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
    if ((nargin>14)
        || (nargout>8)
        || ((nargout<=2) && (nargin<5))
        || ((nargout>2) && (nargout<=6) && (nargin!=9) && (nargin!=13))
        || ((nargout>=7) && ((nargin!=9) && (nargin!=13))))
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

  // Allocate input cell arrays
  Cell dAdx;
  Cell dBdx;
  Cell dCdx;
  Cell dDdx;
  octave_idx_type Nk=A.columns();
  octave_idx_type Nx=0;
  if (nargin>=9)
    {
      dAdx=args(5).cell_value();
      dBdx=args(6).cell_value();
      dCdx=args(7).cell_value();
      dDdx=args(8).cell_value();
      Nx=dAdx.numel();
    }
  Cell d2Adydx;
  Cell d2Bdydx;
  Cell d2Cdydx;
  Cell d2Ddydx;
  if (nargin==13)
    {
      d2Adydx=args(9).cell_value();
      d2Bdydx=args(10).cell_value();
      d2Cdydx=args(11).cell_value();
      d2Ddydx=args(12).cell_value();
    }

  
  // Outputs
  octave_idx_type Nw=w.numel();
  ComplexColumnVector H(nargout>=1 ? Nw : 0);
  ComplexColumnVector dHdw((nargout>=2 ? Nw : 0));
  ComplexMatrix dHdx((nargout>=3 ? Nw : 0),(nargout>=3 ? Nx : 0));
  ComplexMatrix d2Hdwdx((nargout>=4 ? Nw : 0),(nargout>=4 ? Nx : 0)); 
  ComplexMatrix diagd2Hdx2((nargout>=5 ? Nw : 0),(nargout>=5 ? Nx : 0));
  ComplexMatrix diagd3Hdwdx2((nargout>=6 ? Nw : 0),(nargout>=6 ? Nx : 0));
  ComplexNDArray d2Hdydx(dim_vector ( (nargout>=7 ? Nw : 0),
                                    (nargout>=7 ? Nx : 0),
                                    (nargout>=7 ? Nx : 0) ) );
  ComplexNDArray d3Hdwdydx(dim_vector ( (nargout>=8 ? Nw : 0),
                                        (nargout>=8 ? Nx : 0),
                                        (nargout>=8 ? Nx : 0) ) );

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
          if (nargin==13)
            {
              ComplexMatrix d2Adydx_mm = d2Adydx(m,m).complex_matrix_value();
              ComplexColumnVector d2Bdydx_mm =
                d2Bdydx(m,m).complex_column_vector_value();
              ComplexRowVector d2Cdydx_mm =
                d2Cdydx(m,m).complex_row_vector_value();
              Complex d2Ddydx_mm = d2Ddydx(m,m).complex_value();
              diagd2Hdx2(l,m)=diagd2Hdx2(l,m) + (CR*d2Adydx_mm*RB) +
                (CR*d2Bdydx_mm) + (d2Cdydx_mm*RB) + (d2Ddydx_mm);
            }
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
          if (nargin==13)
            {
              ComplexMatrix d2Adydx_mm = d2Adydx(m,m).complex_matrix_value();
              ComplexColumnVector d2Bdydx_mm =
                d2Bdydx(m,m).complex_column_vector_value();
              ComplexRowVector d2Cdydx_mm =
                d2Cdydx(m,m).complex_row_vector_value();
              diagd3Hdwdx2(l,m)=diagd3Hdwdx2(l,m) +
                (CR*d2Adydx_mm*RRB) +
                (CRR*d2Adydx_mm*RB) +
                (CRR*d2Bdydx_mm) +
                (d2Cdydx_mm*RRB);
            }
        } 
      if (nargout == 6)
        {
          continue;
        }

      // Find d2Hdydx
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          for (octave_idx_type n=m;n<Nx;n++)
            { 
              ComplexMatrix dAdx_n=dAdx(n).complex_matrix_value();
              ComplexColumnVector dBdx_n=dBdx(n).complex_column_vector_value();
              ComplexRowVector dCdx_n=dCdx(n).complex_row_vector_value();
              d2Hdydx(l,m,n) =
                (dCdx_n*R*dAdx_m*RB)    +
                (dCdx_n*R*dBdx_m)       +
                (dCdx_m*R*dAdx_n*RB)    +
                (CR*dAdx_m*R*dAdx_n*RB) +
                (CR*dAdx_n*R*dAdx_m*RB) +
                (CR*dAdx_n*R*dBdx_m)    +
                (dCdx_m*R*dBdx_n)       +
                (CR*dAdx_m*R*dBdx_n);
              if (nargin == 13)
                {
                  ComplexMatrix d2Adydx_mn = d2Adydx(m,n).complex_matrix_value();
                  ComplexColumnVector d2Bdydx_mn =
                    d2Bdydx(m,n).complex_column_vector_value();
                  ComplexRowVector d2Cdydx_mn =
                    d2Cdydx(m,n).complex_row_vector_value();
                  Complex d2Ddydx_mn = d2Ddydx(m,n).complex_value();
                  d2Hdydx(l,m,n) = d2Hdydx(l,m,n) + (d2Cdydx_mn*RB) +
                    (CR*d2Adydx_mn*RB) + (CR*d2Bdydx_mn) + d2Ddydx_mn;    
                }
              d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
            }
        }
      if (nargout == 7)
        {
          continue;
        }

      // Find d3Hdwdydx
      for (octave_idx_type m=0;m<Nx;m++)
        { 
          ComplexMatrix dAdx_m=dAdx(m).complex_matrix_value();
          ComplexColumnVector dBdx_m=dBdx(m).complex_column_vector_value();
          ComplexRowVector dCdx_m=dCdx(m).complex_row_vector_value();
          for (octave_idx_type n=m;n<Nx;n++)
            { 
              ComplexMatrix dAdx_n=dAdx(n).complex_matrix_value();
              ComplexColumnVector dBdx_n=dBdx(n).complex_column_vector_value();
              ComplexRowVector dCdx_n=dCdx(n).complex_row_vector_value();
              d3Hdwdydx(l,m,n) = Complex(-1)*jexpjw*( (dCdx_m*RR*dAdx_n*RB)    +
                                                      (dCdx_m*R*dAdx_n*RRB)    +
                                                      (dCdx_m*RR*dBdx_n)       + 
                                                      (dCdx_n*RR*dAdx_m*RB)    + 
                                                      (dCdx_n*R*dAdx_m*RRB)    +
                                                      (CRR*dAdx_n*R*dAdx_m*RB) +
                                                      (CR*dAdx_n*RR*dAdx_m*RB) +
                                                      (CR*dAdx_n*R*dAdx_m*RRB) +
                                                      (CRR*dAdx_m*R*dAdx_n*RB) +
                                                      (CR*dAdx_m*RR*dAdx_n*RB) +
                                                      (CR*dAdx_m*R*dAdx_n*RRB) +
                                                      (CRR*dAdx_m*R*dBdx_n)    +
                                                      (CR*dAdx_m*RR*dBdx_n)    +
                                                      (dCdx_n*RR*dBdx_m)       +
                                                      (CRR*dAdx_n*R*dBdx_m)    +
                                                      (CR*dAdx_n*RR*dBdx_m) );
              if (nargin==13)
                {
                  ComplexMatrix d2Adydx_mn = d2Adydx(m,n).complex_matrix_value();
                  ComplexColumnVector d2Bdydx_mn =
                    d2Bdydx(m,n).complex_column_vector_value();
                  ComplexRowVector d2Cdydx_mn =
                    d2Cdydx(m,n).complex_row_vector_value();
                  d3Hdwdydx(l,m,n) = d3Hdwdydx(l,m,n) +
                    (Complex(-1,0)*jexpjw*( (d2Cdydx_mn*RRB) +
                                            (CRR*d2Adydx_mn*RB) +
                                            (CR*d2Adydx_mn*RRB) +
                                            (CRR*d2Bdydx_mn) ) );
                }
              d3Hdwdydx(l,n,m)=d3Hdwdydx(l,m,n);
            }
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
  if (nargout >= 6)
    {
      retval(5)=diagd3Hdwdx2;
    } 
  if (nargout >= 7)
    {
      retval(6)=d2Hdydx;
    }
  if (nargout >= 8)
    {
      retval(7)=d3Hdwdydx;
    }
  return retval;
}
