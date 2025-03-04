// schurOneMlattice2H.cc
//
// [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...
//   schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx)
// Find the complex response and partial derivatives for a Schur one-multiplier
// lattice filter. The outputs are intermediate results in the calculation of
// the squared-magnitude and group-delay responses and partial derivatives.
// The state transition matrix, A, is assumed to lower-Hessenberg.
// For the Schur one-multiplier lattice, d2Bdydx,d2Cdydx,d2Ddydx are zero.
// See schurOneMAPlattice2H() for the Schur one-multiplier all-pass lattice.
//
// Inputs:
//  w         - column vector of angular frequencies   
//  A,B,C,D - state variable description of the lattice filter
//  dAdkc,dBdkc - cell vectors of the differentials of A and B wrt [k,c]
//  dCdkc,dDdkc - cell vectors of the differentials of C and D wrt [k,c]
//  d2Adydx - cell array of the second derivatives of A wrt [k,c]
//   
// Outputs:
//  H - complex vector of the response over w
//  dHdw - complex vector derivative of the complex response wrt w
//  dHdkc - complex matrix of the derivative of the response wrt [k,c] over w
//  d2Hdwdkc - complex matrix of the mixed second derivative wrt w and [k,c]
//  diagd2Hdkc2 - complex matrix of the diagonal of the matrix of second
//                derivatives of the response wrt [k,c]
//  diagd3Hdwdkc2 - complex matrix of the diagonal of the matrix of second
//                  derivatives of the response wrt [k,c] and wrt frequency
//  d2Hdydx - complex matrix of the second derivatives of H wrt [k,c]
//  d3Hdwdydx - complex matrix of the second derivatives of H wrt [k,c] and wrt w

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

#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(schurOneMlattice2H, args, nargout,
"[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...\n\
  schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin>10)
      || (nargout>8)
      || ((nargout<=2) && (nargin<5))
      || ((nargout>=3) && (nargout<=6) && (nargin<9))
      || ((nargout>=7) && (nargin<10)))
    {
      print_usage();
    }
  
  // Input arguments
  ColumnVector w = args(0).column_vector_value();
  ComplexMatrix A = args(1).complex_matrix_value();  
  ComplexColumnVector B = args(2).complex_column_vector_value();
  ComplexRowVector C = args(3).complex_row_vector_value();
  Complex D(args(4).scalar_value(),0);
  if (A.rows() != B.rows())
    {
      error("A.rows() != B.rows()");
    }
  if (B.columns() != 1)
    {
      error("B.columns() != 1");
    }
  if (A.columns() != C.columns())
    {
      error("A.columns() != C.columns()");
    }
  if (C.rows() != 1)
    {
      error("C.rows() != 1");
    }

  Cell dAdkc;
  Cell dBdkc;
  Cell dCdkc;
  Cell dDdkc;
  Cell d2Adydx;
  octave_idx_type Nk=A.columns();
  octave_idx_type NC=C.columns();
  ComplexMatrix dCdc((nargin>=9 ? NC : 0),(nargin>=9 ? NC : 0));
  Complex dDdc;
  if (nargin>=9)
    {
      dAdkc=args(5).cell_value();
      dBdkc=args(6).cell_value();
      dCdkc=args(7).cell_value();
      dDdkc=args(8).cell_value();
      for (octave_idx_type l=0;l<NC;l++)
        {
          dCdc(l,l)=dCdkc(Nk+l).complex_vector_value()(l);
        }
      dDdc=dDdkc(Nk+NC).complex_value();
    }
  if (nargin==10)
    {
      d2Adydx=args(9).cell_value();
    }
  
  // Outputs
  octave_idx_type Nw=w.numel();
  ComplexColumnVector H(nargout>=1 ? Nw : 0);
  ComplexColumnVector dHdw((nargout>=2 ? Nw : 0));
  ComplexMatrix dHdkc((nargout>=3 ? Nw : 0),
                      (nargout>=3 ? Nk+NC+1 : 0));
  ComplexMatrix d2Hdwdkc((nargout>=4 ? Nw : 0),
                         (nargout>=4 ? Nk+NC+1 : 0)); 
  ComplexMatrix diagd2Hdkc2((nargout>=5 ? Nw : 0),
                            (nargout>=5 ? Nk+NC+1 : 0));
  ComplexMatrix diagd3Hdwdkc2((nargout>=6 ? Nw : 0),
                              (nargout>=6 ? Nk+NC+1 : 0));
  ComplexNDArray d2Hdydx(dim_vector ( (nargout>=7 ? Nw : 0),
                                      (nargout>=7 ? Nk+NC+1 : 0),
                                      (nargout>=7 ? Nk+NC+1 : 0) ));
  ComplexNDArray d3Hdwdydx(dim_vector( (nargout>=8 ? Nw : 0),
                                       (nargout>=8 ? Nk+NC+1 : 0),
                                       (nargout>=8 ? Nk+NC+1 : 0) ));

  // Loop over w
  for (octave_idx_type l=0;l<Nw;l++)
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
      retval=octave::feval("complex_zhong_inverse",argval,1);
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
      
      // Find dHdkc  
      ComplexColumnVector RB(R*B);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
          dHdkc(l,m)=CR*dAdkc_m*RB;
        }
      ComplexColumnVector dBdkc_Nkm1=dBdkc(Nk-1).complex_column_vector_value();
      dHdkc(l,Nk-1)=dHdkc(l,Nk-1)+(CR*dBdkc_Nkm1);
      for (octave_idx_type m=0;m<NC;m++)
        { 
          dHdkc(l,Nk+m)=dCdc.row(m)*RB;
        }
      dHdkc(l,Nk+NC)=dDdc;
      if (nargout == 3)
        {
          continue;
        }

      // Find d2Hdwdkc 
      ComplexColumnVector RRB(R*RB);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
          d2Hdwdkc(l,m)=-jexpjw*((CRR*dAdkc_m*RB)+(CR*dAdkc_m*RRB));
        }
      d2Hdwdkc(l,Nk-1)=d2Hdwdkc(l,Nk-1)-(jexpjw*(CRR*dBdkc_Nkm1));
      for (octave_idx_type m=0;m<NC;m++)
        { 
          d2Hdwdkc(l,Nk+m)=-jexpjw*dCdc.row(m)*RRB;
        }
      d2Hdwdkc(l,Nk+NC)=0;
      if (nargout == 4)
        {
          continue;
        } 

      // Find diagd2Hdkc2 
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
          diagd2Hdkc2(l,m)=(Complex(2,0)*CR*dAdkc_m*R*dAdkc_m*RB);
        } 
      ComplexMatrix dAdkc_Nkm1=dAdkc(Nk-1).complex_matrix_value();
      diagd2Hdkc2(l,Nk-1)=diagd2Hdkc2(l,Nk-1)+
        (Complex(2,0)*CR*dAdkc_Nkm1*R*dBdkc_Nkm1);
      if (nargout == 5)
        {
          continue;
        }

      // Find diagd3Hdwdkc2
      ComplexMatrix RR(R*R);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
          diagd3Hdwdkc2(l,m)=Complex(-2,0)*jexpjw*((CRR*dAdkc_m*R*dAdkc_m*RB) +
                                                   (CR*dAdkc_m*RR*dAdkc_m*RB) +
                                                   (CR*dAdkc_m*R*dAdkc_m*RRB));
        } 
      diagd3Hdwdkc2(l,Nk-1)= diagd3Hdwdkc2(l,Nk-1)+
        Complex(-2,0)*jexpjw*((CRR*dAdkc_Nkm1*R*dBdkc_Nkm1) +
                              (CR*dAdkc_Nkm1*RR*dBdkc_Nkm1));
      if (nargout == 6)
        {
          continue;
        }

      // Find d2Hdydx (second partial derivatives of H wrt x and y)
      ComplexMatrix dAdkc_Nk=dAdkc(Nk-1).complex_matrix_value(); 
      ComplexColumnVector dBdkc_Nk=dBdkc(Nk-1).complex_column_vector_value();
      // dAdkc is non-zero for 0<=m<=Nk-1 and dBdkc is non-zero for Nk-1
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<Nk;n++)
            {
              ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
              ComplexMatrix dAdkc_n=dAdkc(n).complex_matrix_value();
              ComplexMatrix d2Adydx_mn=d2Adydx(m,n).complex_matrix_value();
              d2Hdydx(l,m,n)=(CR*dAdkc_m*R*dAdkc_n*RB) +
                             (CR*dAdkc_n*R*dAdkc_m*RB) +
                             (CR*d2Adydx_mn*RB);
              d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
            }
        }
      // dAdkc is non-zero for 0<=m<=Nk-1 and dBdkc is non-zero for Nk-1
      for (octave_idx_type m=0;m<(Nk-1);m++)
        {
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value(); 
          d2Hdydx(l,m,Nk-1)=d2Hdydx(l,m,Nk-1) + (CR*dAdkc_m*R*dBdkc_Nk);
          d2Hdydx(l,Nk-1,m)=d2Hdydx(l,m,Nk-1);
        }
      d2Hdydx(l,Nk-1,Nk-1)=
        d2Hdydx(l,Nk-1,Nk-1) + (Complex(2.0)*CR*dAdkc_Nk*R*dBdkc_Nk);

      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<(Nk+1);n++)
            {
              ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
              ComplexRowVector dCdkc_Nkn=dCdkc(Nk+n).complex_row_vector_value(); 
              d2Hdydx(l,m,Nk+n)=(dCdkc_Nkn*R*dAdkc_m*RB);
              d2Hdydx(l,Nk+n,m)=d2Hdydx(l,m,Nk+n);
            }
        }
      // dBdkc is non-zero for Nk-1 and dCdkc is non-zero for Nk<=m
      for (octave_idx_type n=0;n<Nk+1;n++)
        {
          ComplexRowVector dCdkc_Nkn=dCdkc(Nk+n).complex_row_vector_value(); 
          d2Hdydx(l,Nk-1,Nk+n)=d2Hdydx(l,Nk-1,Nk+n)+(dCdkc_Nkn*R*dBdkc_Nk);
          d2Hdydx(l,Nk+n,Nk-1)=d2Hdydx(l,Nk-1,Nk+n);
        }
      if (nargout==7)
        {
          continue;
        }

      // Find d3Hdwdydx (second partial derivatives of H wrt x, y and w)
      // dAdkc is non-zero for 0<=m<=Nk-1
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<Nk;n++)
            {
              ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
              ComplexMatrix dAdkc_n=dAdkc(n).complex_matrix_value();
              ComplexMatrix d2Adydx_mn=d2Adydx(m,n).complex_matrix_value();
              d3Hdwdydx(l,m,n)=-jexpjw*( (CRR*dAdkc_n*R*dAdkc_m*RB) +
                                         (CR*dAdkc_n*RR*dAdkc_m*RB) +
                                         (CR*dAdkc_n*R*dAdkc_m*RRB) +
                                         (CRR*dAdkc_m*R*dAdkc_n*RB) +
                                         (CR*dAdkc_m*RR*dAdkc_n*RB) +
                                         (CR*dAdkc_m*R*dAdkc_n*RRB) +
                                         (CRR*d2Adydx_mn*RB)        +
                                         (CR*d2Adydx_mn*RRB) );
            }
        }
      // dAdkc is non-zero for 0<=m<=Nk-1 and dBdkc is non-zero for Nk-1
      for (octave_idx_type m=0;m<(Nk-1);m++)
        {
          ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
          d3Hdwdydx(l,m,Nk-1)=
            d3Hdwdydx(l,m,Nk-1) - (jexpjw*( (CRR*dAdkc_m*R*dBdkc_Nk) +
                                            (CR*dAdkc_m*RR*dBdkc_Nk) ));
          d3Hdwdydx(l,Nk-1,m)=d3Hdwdydx(l,m,Nk-1);
        }
      d3Hdwdydx(l,Nk-1,Nk-1)=d3Hdwdydx(l,Nk-1,Nk-1)
        - (jexpjw*Complex(2.0)*( (CRR*dAdkc_Nk*R*dBdkc_Nk) +
                                 (CR*dAdkc_Nk*RR*dBdkc_Nk) ));
      // dAdkc is non-zero for 0<=m<=Nk-1 and dCdkc is non-zero for Nk<=m
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<(Nk+1);n++)
            {
              ComplexMatrix dAdkc_m=dAdkc(m).complex_matrix_value();
              ComplexRowVector dCdkc_Nkn=dCdkc(Nk+n).complex_row_vector_value();
              d3Hdwdydx(l,m,Nk+n)=-jexpjw*( (dCdkc_Nkn*RR*dAdkc_m*RB) +
                                            (dCdkc_Nkn*R*dAdkc_m*RRB) );
              d3Hdwdydx(l,Nk+n,m)=d3Hdwdydx(l,m,Nk+n);
            }
        }
      // dBdkc is non-zero for Nk-1 and dCdkc is non-zero for Nk<=m
      for (octave_idx_type n=0;n<(Nk+1);n++)
        {
          ComplexRowVector dCdkc_Nkn=dCdkc(Nk+n).complex_row_vector_value();
          d3Hdwdydx(l,Nk-1,Nk+n)=
            d3Hdwdydx(l,Nk-1,Nk+n) - (jexpjw*(dCdkc_Nkn*RR*dBdkc_Nk));
          d3Hdwdydx(l,Nk+n,Nk-1)=d3Hdwdydx(l,Nk-1,Nk+n);
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
      retval(2)=dHdkc;
    }
  if (nargout >= 4)
    {
      retval(3)=d2Hdwdkc;
    }
  if (nargout >= 5)
    {
      retval(4)=diagd2Hdkc2;
    }
  if (nargout >= 6)
    {
      retval(5)=diagd3Hdwdkc2;
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
