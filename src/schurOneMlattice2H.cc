// schurOneMlattice2H.cc
//
// [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
//   schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc)
// Find the complex response and partial derivatives for a Schur one-multiplier
// lattice filter. The outputs are intermediate results in the calculation of
// the squared-magnitude and group-delay responses and partial derivatives.
// The state transition matrix, A, is assumed to lower-Hessenberg.
// Inputs:
//  w         - column vector of angular frequencies   
//  A,B,C,D - state variable description of the lattice filter
//  dAdkc,dBdkc - cell vectors of the differentials of A and B wrt [k,c]
//  dCdkc,dDdkc - cell vectors of the differentials of C and D wrt [k,c]
// Outputs:
//  H - complex vector of the response over w
//  dHdw - complex vector derivative of the complex response wrt w
//  dHdkc - complex matrix of the derivative of the response wrt [k,c] over w
//  d2Hdwdkc - complex matrix of the mixed second derivative wrt w and [k,c]
//  diagd2Hdkc2 - complex matrix of the diagonal of the matrix of second
//                derivatives of the response wrt [k,c]
//  diagd3Hdwdkc2 - complex matrix of the diagonal of the matrix of second
//                  derivatives of the response wrt [k,c] and wrt frequency

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

DEFUN_DLD(schurOneMlattice2H, args, nargout,
"[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...\n\
  schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc)")
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
  Cell dAdkc;
  Cell dBdkc;
  Cell dCdkc;
  Cell dDdkc;
  octave_idx_type Nk=A.columns();
  octave_idx_type NC=C.columns();
  ComplexMatrix dCdc((nargin==9 ? NC : 0),(nargin==9 ? NC : 0));
  Complex dDdc;
  if (nargin==9)
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
          diagd2Hdkc2(l,m)=Complex(2,0)*CR*dAdkc_m*R*dAdkc_m*RB;
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
  if (nargout == 6)
    {
      retval(5)=diagd3Hdwdkc2;
    }
  return retval;
}
