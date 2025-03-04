// schurOneMAPlattice2H.cc
//
// [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...
//  schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk,d2Adydx,d2Capdydx)
// Find the complex response and partial derivatives for a Schur
// one-multiplier allpass lattice filter. The outputs are intermediate
// results in the calculation of the squared-magnitude and group-delay
// responses and partial derivatives. The state transition matrix, A, is
// assumed to lower-Hessenberg.
//
// Inputs:
//  w - column vector of angular frequencies   
//  A,B,Cap,Dap - state variable description of the allpass lattice filter
//  dAdk - cell array of matrixes of the differentials of A wrt k
//  dBdk - cell array of column vectors of the differentials of B wrt k
//  dCapdk - cell array of row vectors of the differentials of Cap wrt k
//  dDapdk - cell array of the scalar differential of Dap wrt k
//  d2Adydx - cell array of matrixes of the 2nd differentials of A wrt k
//  d2Capdxdy - cell array of row vectors of the 2nd differentials of Cap wrt k
//
// Outputs:
//  H - complex vector of response wrt w
//  dHdw - complex vector of the derivative of the response wrt w
//  dHdk - complex matrix of the derivative of the response wrt k
//  d2Hdwdk - complex matrixes of the derivative of the response wrt k and w
//  diagd2Hdk2,diagd3Hdwdk2 - diagonals of the complex matrixes of the mixed
//                            second derivatives of the response
//  d2Hdydx,d3Hdwdydx - complex matrixes of the mixed second derivatives of the
//                      response
//

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

DEFUN_DLD(schurOneMAPlattice2H, args, nargout,
"[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...\n\
  schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk,d2Adydx,d2Capdydx)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin>11) || (nargout>8)
      || ((nargout<=2) && (nargin<5))
      || (((nargout>=3) && (nargout<=6)) && (nargin<9))
      || ((nargout>=7) && (nargin<11)))
    {
      print_usage();
    }
  
  // Input arguments
  ColumnVector w = args(0).column_vector_value();
  ComplexMatrix A = args(1).complex_matrix_value();  
  ComplexColumnVector B = args(2).complex_column_vector_value();
  ComplexRowVector Cap = args(3).complex_row_vector_value();
  Complex Dap(args(4).scalar_value(),0);
  if (A.rows() != B.rows())
    {
      error("A.rows() != B.rows()");
    }
  if (B.columns() != 1)
    {
      error("B.columns() != 1");
    }
  if (A.columns() != Cap.columns())
    {
      error("A.columns() != Cap.columns()");
    }
  if (Cap.rows() != 1)
    {
      error("Cap.rows() != 1");
    }
  
  Cell dAdk;
  Cell dBdk;
  Cell dCapdk;
  Cell dDapdk;
  Cell d2Adydx;
  Cell d2Capdydx;
  octave_idx_type Nk=A.columns();
  if (nargin>=9)
    {
      dAdk=args(5).cell_value();
      dBdk=args(6).cell_value();
      dCapdk=args(7).cell_value();
      dDapdk=args(8).cell_value();
    }
  if (nargin>=10)
    {
      d2Adydx=args(9).cell_value();
   }
  if (nargin==11)
    {
      d2Capdydx=args(10).cell_value();
   }

  // Outputs
  octave_idx_type Nw=w.numel();  
  ComplexColumnVector H(nargout>=1 ? Nw : 0);
  ComplexColumnVector dHdw((nargout>=2 ? Nw : 0)); 
  ComplexMatrix dHdk((nargout>=3 ? Nw : 0),(nargout>=3 ? Nk : 0));
  ComplexMatrix d2Hdwdk((nargout>=4 ? Nw : 0),(nargout>=4 ? Nk : 0));
  ComplexMatrix diagd2Hdk2((nargout>=5 ? Nw : 0),(nargout>=5 ? Nk : 0));
  ComplexMatrix diagd3Hdwdk2((nargout>=6 ? Nw : 0),(nargout>=6 ? Nk : 0));
  ComplexNDArray d2Hdydx(dim_vector ( (nargout>=7 ? Nw : 0),
                                      (nargout>=7 ? Nk : 0),
                                      (nargout>=7 ? Nk : 0) ));
  ComplexNDArray d3Hdwdydx(dim_vector( (nargout>=8 ? Nw : 0),
                                       (nargout>=8 ? Nk : 0),
                                       (nargout>=8 ? Nk : 0) ));

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
      if (nargout == 6)
        {
          continue;
        }

      // Find d2Hdydx (second partial derivatives of H wrt x and y)
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<Nk;n++)
            {
              ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
              ComplexMatrix dAdk_n=dAdk(n).complex_matrix_value();
              ComplexMatrix d2Adydx_mn=d2Adydx(m,n).complex_matrix_value();
              ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
              ComplexRowVector dCapdk_n=dCapdk(n).complex_row_vector_value();
              ComplexRowVector d2Capdydx_mn=
                d2Capdydx(m,n).complex_row_vector_value();
              d2Hdydx(l,m,n)=(d2Capdydx_mn*RB) +
                             (dCapdk_m*R*dAdk_n*RB) + 
                             (dCapdk_n*R*dAdk_m*RB) + 
                             (CapR*dAdk_m*R*dAdk_n*RB) +
                             (CapR*dAdk_n*R*dAdk_m*RB) +
                             (CapR*d2Adydx_mn*RB);
              d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
            }
        }
      // dAdk is non-zero for 0<=m<=Nk-1 and dBdk is non-zero for Nk-1
      ComplexColumnVector dBdk_Nk=dBdk(Nk-1).complex_column_vector_value();
      for (octave_idx_type m=0;m<(Nk-1);m++)
        {
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value(); 
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          d2Hdydx(l,m,Nk-1)=d2Hdydx(l,m,Nk-1) +
            (dCapdk_m*R*dBdk_Nk) +
            (CapR*dAdk_m*R*dBdk_Nk);
          d2Hdydx(l,Nk-1,m)=d2Hdydx(l,m,Nk-1);
        }
      ComplexMatrix dAdk_Nk=dAdk(Nk-1).complex_matrix_value(); 
      ComplexRowVector dCapdk_Nk=dCapdk(Nk-1).complex_row_vector_value();
      d2Hdydx(l,Nk-1,Nk-1)=
        d2Hdydx(l,Nk-1,Nk-1) +
        (Complex(2.0)*dCapdk_Nk*R*dBdk_Nk) +
        (Complex(2.0)*CapR*dAdk_Nk*R*dBdk_Nk);
      if (nargout==7)
        {
          continue;
        }

      // Find d3Hdwdydx (second partial derivatives of H wrt x, y and w)
      // dAdk is non-zero for 0<=m<=Nk-1
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<Nk;n++)
            {
              ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
              ComplexMatrix dAdk_n=dAdk(n).complex_matrix_value();
              ComplexMatrix d2Adydx_mn=d2Adydx(m,n).complex_matrix_value();
              ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
              ComplexRowVector dCapdk_n=dCapdk(n).complex_row_vector_value();
              ComplexRowVector d2Capdydx_mn=
                d2Capdydx(m,n).complex_row_vector_value();
              d3Hdwdydx(l,m,n)=-jexpjw*( (d2Capdydx_mn*RRB)         +
                                         (CapRR*d2Adydx_mn*RB)      +
                                         (CapR*d2Adydx_mn*RRB)      +
                                         (dCapdk_m*RR*dAdk_n*RB)  +
                                         (dCapdk_m*R*dAdk_n*RRB)  +
                                         (dCapdk_n*RR*dAdk_m*RB)  +
                                         (dCapdk_n*R*dAdk_m*RRB)  +
                                         (CapRR*dAdk_m*R*dAdk_n*RB) +
                                         (CapR*dAdk_m*RR*dAdk_n*RB) +
                                         (CapR*dAdk_m*R*dAdk_n*RRB) +
                                         (CapRR*dAdk_n*R*dAdk_m*RB) +
                                         (CapR*dAdk_n*RR*dAdk_m*RB) +
                                         (CapR*dAdk_n*R*dAdk_m*RRB) );
            }
        }
      // dAdk is non-zero for 0<=m<=Nk-1 and dBdk is non-zero for Nk-1
      for (octave_idx_type m=0;m<(Nk-1);m++)
        {
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          ComplexRowVector dCapdk_m=dCapdk(m).complex_row_vector_value();
          d3Hdwdydx(l,m,Nk-1)=
            d3Hdwdydx(l,m,Nk-1) - (jexpjw*( (dCapdk_m*RR*dBdk_Nk) +
                                            (CapR*dAdk_m*RR*dBdk_Nk) +
                                            (CapRR*dAdk_m*R*dBdk_Nk) ));
          d3Hdwdydx(l,Nk-1,m)=d3Hdwdydx(l,m,Nk-1);
        }
      d3Hdwdydx(l,Nk-1,Nk-1)=d3Hdwdydx(l,Nk-1,Nk-1)
        - (jexpjw*Complex(2.0)*( (dCapdk_Nk*RR*dBdk_Nk) +
                                 (CapR*dAdk_Nk*RR*dBdk_Nk) +
                                 (CapRR*dAdk_Nk*R*dBdk_Nk) ));
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
