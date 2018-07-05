// schurOneMAPlattice2H.cc
//
// [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...
//   schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk)
// Find the complex response and partial derivatives for a Schur
// one-multiplier allpass lattice filter. The outputs are intermediate
// results in the calculation of the squared-magnitude and group-delay
// responses and partial derivatives. The state transition matrix, A, is
// assumed to lower-Hessenberg.
// Inputs:
//  w - column vector of angular frequencies   
//  A,B,Cap,Dap - state variable description of the allpass lattice filter
//  dAdk - cell array of matrixes of the differentials of A wrt k
//  dBdk - cell array of column vectors of the differentials of B wrt k
//  dCapdk - cell array of row vectors of the differentials of C wrt k
//  dDapdk - cell array of the scalar differential of Dap wrt k
// Outputs:
//  H - complex vector of response wrt w
//  dHdw - complex vector of the derivative of the complex response wrt w
//  dHdk - complex matrix of the derivative of the complex response wrt k and w
//  d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2 - complex matrixes of the mixed second
//                                    derivatives of the response
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

#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(schurOneMAPlattice2H, args, nargout,
"[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...\n\
  schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk)")
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
  ComplexRowVector Cap = args(3).complex_row_vector_value();
  Complex Dap(args(4).scalar_value(),0);
  Cell dAdk;
  Cell dBdk;
  Cell dCapdk;
  Cell dDapdk;
  if (nargin==9)
    {
      dAdk=args(5).cell_value();
      dBdk=args(6).cell_value();
      dCapdk=args(7).cell_value();
      dDapdk=args(8).cell_value();
    }

  // Outputs
  octave_idx_type Nw=w.numel();  
  octave_idx_type Nk=A.columns();
  ComplexColumnVector H(nargout>=1 ? Nw : 0);
  ComplexColumnVector dHdw((nargout>=2 ? Nw : 0)); 
  ComplexMatrix dHdk((nargout>=3 ? Nw : 0),(nargout>=3 ? Nk : 0));
  ComplexMatrix d2Hdwdk((nargout>=4 ? Nw : 0),(nargout>=4 ? Nk : 0));
  ComplexMatrix diagd2Hdk2((nargout>=5 ? Nw : 0),(nargout>=5 ? Nk : 0));
  ComplexMatrix diagd3Hdwdk2((nargout>=6 ? Nw : 0),(nargout>=6 ? Nk : 0));
  
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
      ComplexRowVector CapR(Cap*R);
      Complex CapRB(CapR*B);
      H(l)=CapRB+Dap;
      if (nargout == 1)
        {
          continue;
        }

      // Find dHdw
      ComplexRowVector CapRR(CapR*R);
      Complex CapRRB(CapRR*B);
      Complex jexpjw(Complex(0,1)*expjw);
      dHdw(l)=-jexpjw*CapRRB;
      if (nargout == 2)
        {
          continue;
        }
      
      // Find dHdk
      ComplexColumnVector RB(R*B);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          dHdk(l,m)=(dCapdk_m*RB)+(CapR*dAdk_m*RB);
        }
      ComplexColumnVector dBdk_Nkm1=dBdk(Nk-1).complex_column_vector_value();
      Complex dDapdk_Nkm1=dDapdk(Nk-1).complex_value();
      dHdk(l,Nk-1)=dHdk(l,Nk-1)+(CapR*dBdk_Nkm1)+dDapdk_Nkm1;
      if (nargout == 3)
        {
          continue;
        }

      // Find d2Hdwdk
      ComplexColumnVector RRB(R*RB);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          d2Hdwdk(l,m)=-jexpjw*((dCapdk_m*RRB)+(CapRR*dAdk_m*RB)+
                                (CapR*dAdk_m*RRB));
        }
      d2Hdwdk(l,Nk-1)=d2Hdwdk(l,Nk-1)-(jexpjw*CapRR*dBdk_Nkm1);
      if (nargout == 4)
        {
          continue;
        }

      // Find diagd2Hdk2
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          diagd2Hdk2(l,m)=Complex(2,0)*((dCapdk_m*R*dAdk_m*RB)+
                                        (CapR*dAdk_m*R*dAdk_m*RB));
        }
      ComplexMatrix dAdk_Nkm1=dAdk(Nk-1).complex_matrix_value();
      ComplexRowVector dCapdk_Nkm1=dCapdk(Nk-1).complex_row_vector_value();
      diagd2Hdk2(l,Nk-1)=diagd2Hdk2(l,Nk-1)+
        (Complex(2,0)*((dCapdk_Nkm1*R*dBdk_Nkm1)+
                       (CapR*dAdk_Nkm1*R*dBdk_Nkm1)));
      if (nargout == 5)
        {
          continue;
        }

      // Find diagd3Hdwdk2
      ComplexMatrix RR(R*R);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          diagd3Hdwdk2(l,m)=
            Complex(-2,0)*jexpjw*((CapRR*dAdk_m*R*dAdk_m*RB) + 
                                  (CapR*dAdk_m*RR*dAdk_m*RB) + 
                                  (CapR*dAdk_m*R*dAdk_m*RRB) + 
                                  (dCapdk_m*RR*dAdk_m*RB) +
                                  (dCapdk_m*R*dAdk_m*RRB));
        }
      diagd3Hdwdk2(l,Nk-1)=diagd3Hdwdk2(l,Nk-1)+
        Complex(-2,0)*jexpjw*((CapRR*dAdk_Nkm1*R*dBdk_Nkm1)+
                              (CapR*dAdk_Nkm1*RR*dBdk_Nkm1)+
                              (dCapdk_Nkm1*RR*dBdk_Nkm1));
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
      retval(2)=dHdk;
    }
  if (nargout >= 4)
    {
      retval(3)=d2Hdwdk;
    }
  if (nargout >= 5)
    {
      retval(4)=diagd2Hdk2;
    }
  if (nargout >= 6)
    {
      retval(5)=diagd3Hdwdk2;
    }
  return retval;
}
