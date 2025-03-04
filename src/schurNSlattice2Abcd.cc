// schurNSlattice2Abcd.cc
//
// [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
//   schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)
// Find the state variable matrixes and gradients for a Schur normalised-scaled
// lattice filter.
// Inputs:
//  s10,s11,s20,s00,s02,s22 - normalised-scaled lattice filter coefficients.
//                            (s02=-s20 and s22=s00 if they are not present).
// Outputs:
//  [A,B;C,D]               - state variable description of the lattice filter
//  Cap,Dap                 - corresponding matrixes for the all-pass filter
//  dAds,dBds,dCds,dDds     - cell vectors of the gradients of A, B, C and D
//  dCapds,dDapds           - cell vectors of the gradients of Cap and Dap
//
// The output gradient cell vectors are ordered by section:
//   dAds=[dAds10(0),...,dAds22(0),dAds10(1),...]
//
//                       !!! WARNING !!!
//
// As the filter order increases, schurNSlattice2Abcd is increasingly inaccurate.
// See schurNSlattice2Abcd_test.m and compare with schurOneMlattice2Abcd_test.m.
// Rewrite this function with extra precision using the Eigen or MPFR libraries!

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

#include <cstring>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(schurNSlattice2Abcd, args, nargout,
"[A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...\n\
  schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if (((nargin!=4)&&(nargin!=6)) || (nargout>12))
    {
      print_usage();
      return octave_value_list();
     }

  // Input arguments
  RowVector s10 = args(0).row_vector_value();
  RowVector s11 = args(1).row_vector_value();
  RowVector s20 = args(2).row_vector_value();
  RowVector s00 = args(3).row_vector_value();
  RowVector s02 = (nargin==6 ? args(4).row_vector_value() : -RowVector(s20));
  RowVector s22 = (nargin==6 ? args(5).row_vector_value() :  RowVector(s00));
  octave_idx_type Ns=s10.numel();
  if ((Ns!=s11.numel()) || (Ns!=s20.numel()) || (Ns!=s00.numel())
      || (Ns!=s02.numel()) || (Ns!=s22.numel()))
    {
      error("Input vector lengths inconsistent!");
      return octave_value_list();
    }
  if (Ns==0)
    {
      error("Input vectors are empty!");
      return octave_value_list();
    }

  //
  // Calculate the state variable matrixes
  //
  
  // Outputs
  Matrix A(Ns,Ns);
  ColumnVector B(Ns);
  RowVector C(Ns);
  double D;
  RowVector Cap(Ns);
  double Dap;
  
  // Modules 1 to Ns
  Matrix ABCD0(Ns+2,Ns+1);
  memset(ABCD0.fortran_vec(),0,ABCD0.byte_size());
  ABCD0(0,0)=1;
  for (octave_idx_type l=0;l<Ns+1;l++)
    {
      ABCD0(l+1,l)=1;
    }
  Matrix eyeNsp2(Ns+2,Ns+2);
  memset(eyeNsp2.fortran_vec(),0,eyeNsp2.byte_size());
  for (octave_idx_type l=0;l<Ns+2;l++)
    {
      eyeNsp2(l,l)=1;
    }
  Matrix ABCD(ABCD0);
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix ABCDm(eyeNsp2);
      ABCDm(l,  l  )=s02(l);
      ABCDm(l,  l+1)=0;
      ABCDm(l,  l+2)=s00(l);
      ABCDm(l+1,l  )=s22(l);
      ABCDm(l+1,l+1)=0;
      ABCDm(l+1,l+2)=s20(l);
      ABCDm(l+2,l  )=0;
      ABCDm(l+2,l+1)=s11(l);
      ABCDm(l+2,l+2)=s10(l);
      ABCD=ABCDm*ABCD;
    }
  
  // Extract state variable description
  for (octave_idx_type l=0;l<Ns;l++)
    {
      for (octave_idx_type m=0;m<Ns;m++)
        {
          A(l,m)=ABCD(l,m);
        }
      B(l)=ABCD(l,Ns);
      C(l)=ABCD(Ns+1,l);
      Cap(l)=ABCD(Ns,l);
    }
  D=ABCD(Ns+1,Ns);
  Dap=ABCD(Ns,Ns);

  // Done?
  octave_value_list retval(nargout);
  if (nargout >= 1)
    {
      retval(0)=A;
    }
  if (nargout >= 2)
    {
      retval(1)=B;
    }
  if (nargout >= 3)
    {
      retval(2)=C;
    }
  if (nargout >= 4)
    {
      retval(3)=D;
    }
  if (nargout >= 5)
    {
      retval(4)=Cap;
    }
  if (nargout >= 6)
    {
      retval(5)=Dap;
    }
  if (nargout <= 6)
    {
      return retval;
    }
  
  //
  // Calculate the differentials of A,B,C,D,Cap and Dap with respect to s
  //

  // Allocate cell arrays for the gradient matrixes
  Cell dAds(1,Ns*6);
  Cell dBds(1,Ns*6);
  Cell dCds(1,Ns*6);
  Cell dDds(1,Ns*6);
  Cell dCapds(1,Ns*6);
  Cell dDapds(1,Ns*6);

  if (nargin == 6)
    {
      void schurNSlattice2Abcd_helper
        (RowVector &s10,RowVector &s11,RowVector &s20,RowVector &s00,
         RowVector &s02,RowVector &s22,
         Cell &dAds,Cell &dBds,Cell &dCds,Cell &dDds,Cell &dCapds,Cell &dDapds);
      
      schurNSlattice2Abcd_helper
        (s10,s11,s20,s00,s02,s22,dAds,dBds,dCds,dDds,dCapds,dDapds);
    }
  else
    {
      void schurNSlattice2Abcd_symmetric_helper
        (RowVector &s10,RowVector &s11,RowVector &s20,RowVector &s00,
         Cell &dAds,Cell &dBds,Cell &dCds,Cell &dDds,Cell &dCapds,Cell &dDapds);
      
      schurNSlattice2Abcd_symmetric_helper
        (s10,s11,s20,s00,dAds,dBds,dCds,dDds,dCapds,dDapds);
    }

  // Done
  if (nargout >= 7)
    {
      retval(6)=dAds;
    }
  if (nargout >= 8)
    {
      retval(7)=dBds;
    }
  if (nargout >= 9)
    {
      retval(8)=dCds;
    }
  if (nargout >= 10)
    {
      retval(9)=dDds;
    }
  if (nargout >= 11)
    {
      retval(10)=dCapds;
    }
  if (nargout >= 12)
    {
      retval(11)=dDapds;
    }
  return retval;
}

void schurNSlattice2Abcd_helper
 (RowVector &s10,RowVector &s11,RowVector &s20,RowVector &s00,
  RowVector &s02,RowVector &s22,
  Cell &dAds,Cell &dBds,Cell &dCds,Cell &dDds,Cell &dCapds,Cell &dDapds)
{
  // Find modules 1 to Ns (again!)
  octave_idx_type Ns=s10.numel();
  Matrix eyeNsp2(Ns+2,Ns+2);
  memset(eyeNsp2.fortran_vec(),0,eyeNsp2.byte_size());
  for (octave_idx_type l=0;l<Ns+2;l++)
    {
      eyeNsp2(l,l)=1;
    }
  Cell ABCDm(1,Ns);
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix ABCDm_tmp(eyeNsp2);
      ABCDm_tmp(l,  l  )=s02(l);
      ABCDm_tmp(l,  l+1)=0;
      ABCDm_tmp(l,  l+2)=s00(l);
      ABCDm_tmp(l+1,l  )=s22(l);
      ABCDm_tmp(l+1,l+1)=0;
      ABCDm_tmp(l+1,l+2)=s20(l);
      ABCDm_tmp(l+2,l  )=0;
      ABCDm_tmp(l+2,l+1)=s11(l);
      ABCDm_tmp(l+2,l+2)=s10(l);
      ABCDm(l)=ABCDm_tmp;
    }

  // Find RHS cumulative product of the modules
  // (Octave index order is 1,2*1,...,(Ns-1)*...*1,Ns*...*1)
  Matrix ABCD0(Ns+2,Ns+1);
  memset(ABCD0.fortran_vec(),0,ABCD0.byte_size());
  ABCD0(0,0)=1;
  for (octave_idx_type l=0;l<Ns+1;l++)
    {
      ABCD0(l+1,l)=1;
    }
  Cell prodABCDm_rhs(1,Ns);
  prodABCDm_rhs(0)=ABCDm(0).matrix_value()*ABCD0;
  for (octave_idx_type l=1;l<Ns;l++)
    {
      prodABCDm_rhs(l)=
        ABCDm(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
    }

  // Find LHS cumulative product of the modules
  // (Octave index order is Ns*..*1,Ns*..*2,..,Ns*(Ns-1),Ns)
  Cell prodABCDm_lhs(1,Ns);
  prodABCDm_lhs(Ns-1)=ABCDm(Ns-1).matrix_value(); 
  if (Ns>1)
    {
      for (octave_idx_type l=(Ns-2);l>=1;l=l-1)
        {
          prodABCDm_lhs(l)=
            prodABCDm_lhs(l+1).matrix_value()*ABCDm(l).matrix_value();
        }
      prodABCDm_lhs(0)=
        prodABCDm_lhs(1).matrix_value()*ABCDm(0).matrix_value();
    }

  // Find differentials with respect to s of the modules
  Cell dABCDmds10(1,Ns);
  Cell dABCDmds11(1,Ns);
  Cell dABCDmds20(1,Ns);
  Cell dABCDmds00(1,Ns);
  Cell dABCDmds02(1,Ns);
  Cell dABCDmds22(1,Ns);
  Matrix zerosNsp2(Ns+2,Ns+2);
  memset(zerosNsp2.fortran_vec(),0,zerosNsp2.byte_size());
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix dABCDmds_tmp(zerosNsp2);

      dABCDmds_tmp(l+2,l+2)=1;
      dABCDmds10(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+2,l+2)=0;

      dABCDmds_tmp(l+2,l+1)=1;
      dABCDmds11(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+2,l+1)=0;

      dABCDmds_tmp(l+1,l+2)=1;
      dABCDmds20(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+1,l+2)=0;
      
      dABCDmds_tmp(l,l+2)=1;
      dABCDmds00(l)=dABCDmds_tmp;
      dABCDmds_tmp(l,l+2)=0;
      
      dABCDmds_tmp(l,l)=1;
      dABCDmds02(l)=dABCDmds_tmp;
      dABCDmds_tmp(l,l)=0;
      
      dABCDmds_tmp(l+1,l)=1;
      dABCDmds22(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+1,l)=0;
    }
  
  // Find differentials with respect to s of [A,B;C,D]
  Cell dABCDds10(1,Ns);
  Cell dABCDds11(1,Ns);
  Cell dABCDds20(1,Ns);
  Cell dABCDds00(1,Ns);
  Cell dABCDds02(1,Ns);
  Cell dABCDds22(1,Ns);
  if (Ns==1)
    {
      dABCDds10(0)=dABCDmds10(0).matrix_value()*ABCD0;
      dABCDds11(0)=dABCDmds11(0).matrix_value()*ABCD0;
      dABCDds20(0)=dABCDmds20(0).matrix_value()*ABCD0;
      dABCDds00(0)=dABCDmds00(0).matrix_value()*ABCD0;
      dABCDds02(0)=dABCDmds02(0).matrix_value()*ABCD0;
      dABCDds22(0)=dABCDmds22(0).matrix_value()*ABCD0;
    }
  else
    {
      dABCDds10(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds10(0).matrix_value()*ABCD0;
      dABCDds11(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds11(0).matrix_value()*ABCD0;
      dABCDds20(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds20(0).matrix_value()*ABCD0;
      dABCDds00(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds00(0).matrix_value()*ABCD0;
      dABCDds02(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds02(0).matrix_value()*ABCD0;
      dABCDds22(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds22(0).matrix_value()*ABCD0;
  
      for (octave_idx_type l=1;l<(Ns-1);l++)
        {
          dABCDds10(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds10(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds11(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds11(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds20(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds20(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds00(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds00(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds02(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds02(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds22(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds22(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
        }   
      dABCDds10(Ns-1)=
        dABCDmds10(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds11(Ns-1)=
        dABCDmds11(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds20(Ns-1)=
        dABCDmds20(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds00(Ns-1)=
        dABCDmds00(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds02(Ns-1)=
        dABCDmds02(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds22(Ns-1)=
        dABCDmds22(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
    }
  
  // Make the gradient matrixes for the s coefficients
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix dAds_tmp(Ns,Ns);
      ColumnVector dBds_tmp(Ns);
      RowVector dCds_tmp(Ns);
      RowVector dCapds_tmp(Ns);
      double dDds_tmp;
      double dDapds_tmp;

      // s10
      Matrix dABCDds10_tmp(dABCDds10(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds10_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds10_tmp(m,Ns);
          dCds_tmp(m)=dABCDds10_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds10_tmp(Ns,m);
        }
      dDds_tmp=dABCDds10_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds10_tmp(Ns,Ns);
      // Set the output cell values for the s10 coefficients
      dAds((l*6)+0)=dAds_tmp;
      dBds((l*6)+0)=dBds_tmp;
      dCds((l*6)+0)=dCds_tmp;
      dDds((l*6)+0)=dDds_tmp;
      dCapds((l*6)+0)=dCapds_tmp;
      dDapds((l*6)+0)=dDapds_tmp;

      // s11
      Matrix dABCDds11_tmp(dABCDds11(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds11_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds11_tmp(m,Ns);
          dCds_tmp(m)=dABCDds11_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds11_tmp(Ns,m);
        }
      dDds_tmp=dABCDds11_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds11_tmp(Ns,Ns);
      // Set the output cell values for the s11 coefficients
      dAds((l*6)+1)=dAds_tmp;
      dBds((l*6)+1)=dBds_tmp;
      dCds((l*6)+1)=dCds_tmp;
      dDds((l*6)+1)=dDds_tmp;
      dCapds((l*6)+1)=dCapds_tmp;
      dDapds((l*6)+1)=dDapds_tmp;

      // s20
      Matrix dABCDds20_tmp(dABCDds20(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds20_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds20_tmp(m,Ns);
          dCds_tmp(m)=dABCDds20_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds20_tmp(Ns,m);
        }
      dDds_tmp=dABCDds20_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds20_tmp(Ns,Ns);
      // Set the output cell values for the s20 coefficients
      dAds((l*6)+2)=dAds_tmp;
      dBds((l*6)+2)=dBds_tmp;
      dCds((l*6)+2)=dCds_tmp;
      dDds((l*6)+2)=dDds_tmp;
      dCapds((l*6)+2)=dCapds_tmp;
      dDapds((l*6)+2)=dDapds_tmp;

      // s00
      Matrix dABCDds00_tmp(dABCDds00(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds00_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds00_tmp(m,Ns);
          dCds_tmp(m)=dABCDds00_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds00_tmp(Ns,m);
        }
      dDds_tmp=dABCDds00_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds00_tmp(Ns,Ns);
      // Set the output cell values for the s00 coefficients
      dAds((l*6)+3)=dAds_tmp;
      dBds((l*6)+3)=dBds_tmp;
      dCds((l*6)+3)=dCds_tmp;
      dDds((l*6)+3)=dDds_tmp;
      dCapds((l*6)+3)=dCapds_tmp;
      dDapds((l*6)+3)=dDapds_tmp;

      // s02
      Matrix dABCDds02_tmp(dABCDds02(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds02_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds02_tmp(m,Ns);
          dCds_tmp(m)=dABCDds02_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds02_tmp(Ns,m);
        }
      dDds_tmp=dABCDds02_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds02_tmp(Ns,Ns);
      // Set the output cell values for the s02 coefficients
      dAds((l*6)+4)=dAds_tmp;
      dBds((l*6)+4)=dBds_tmp;
      dCds((l*6)+4)=dCds_tmp;
      dDds((l*6)+4)=dDds_tmp;
      dCapds((l*6)+4)=dCapds_tmp;
      dDapds((l*6)+4)=dDapds_tmp;

      // s22
      Matrix dABCDds22_tmp(dABCDds22(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds22_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds22_tmp(m,Ns);
          dCds_tmp(m)=dABCDds22_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds22_tmp(Ns,m);
        }
      dDds_tmp=dABCDds22_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds22_tmp(Ns,Ns);
      // Set the output cell values for the s22 coefficients
      dAds((l*6)+5)=dAds_tmp;
      dBds((l*6)+5)=dBds_tmp;
      dCds((l*6)+5)=dCds_tmp;
      dDds((l*6)+5)=dDds_tmp;
      dCapds((l*6)+5)=dCapds_tmp;
      dDapds((l*6)+5)=dDapds_tmp;
    }
}

void schurNSlattice2Abcd_symmetric_helper
 (RowVector &s10,RowVector &s11,RowVector &s20,RowVector &s00,
  Cell &dAds,Cell &dBds,Cell &dCds,Cell &dDds,Cell &dCapds,Cell &dDapds)
{
  // Find modules 1 to Ns (again!)
  octave_idx_type Ns=s10.numel();
  Matrix eyeNsp2(Ns+2,Ns+2);
  memset(eyeNsp2.fortran_vec(),0,eyeNsp2.byte_size());
  for (octave_idx_type l=0;l<Ns+2;l++)
    {
      eyeNsp2(l,l)=1;
    }
  Cell ABCDm(1,Ns);
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix ABCDm_tmp(eyeNsp2);
      ABCDm_tmp(l,  l  )=-s20(l);
      ABCDm_tmp(l,  l+1)=0;
      ABCDm_tmp(l,  l+2)=s00(l);
      ABCDm_tmp(l+1,l  )=s00(l);
      ABCDm_tmp(l+1,l+1)=0;
      ABCDm_tmp(l+1,l+2)=s20(l);
      ABCDm_tmp(l+2,l  )=0;
      ABCDm_tmp(l+2,l+1)=s11(l);
      ABCDm_tmp(l+2,l+2)=s10(l);
      ABCDm(l)=ABCDm_tmp;
    }

  // Find RHS cumulative product of the modules
  // (Octave index order is 1,2*1,...,(Ns-1)*...*1,Ns*...*1)
  Matrix ABCD0(Ns+2,Ns+1);
  memset(ABCD0.fortran_vec(),0,ABCD0.byte_size());
  ABCD0(0,0)=1;
  for (octave_idx_type l=0;l<Ns+1;l++)
    {
      ABCD0(l+1,l)=1;
    }
  Cell prodABCDm_rhs(1,Ns);
  prodABCDm_rhs(0)=ABCDm(0).matrix_value()*ABCD0;
  for (octave_idx_type l=1;l<Ns;l++)
    {
      prodABCDm_rhs(l)=
        ABCDm(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
    }

  // Find LHS cumulative product of the modules
  // (Octave index order is Ns*..*1,Ns*..*2,..,Ns*(Ns-1),Ns)
  Cell prodABCDm_lhs(1,Ns);
  prodABCDm_lhs(Ns-1)=ABCDm(Ns-1).matrix_value(); 
  if (Ns>1)
    {
      for (octave_idx_type l=(Ns-2);l>=1;l=l-1)
        {
          prodABCDm_lhs(l)=
            prodABCDm_lhs(l+1).matrix_value()*ABCDm(l).matrix_value();
        }
      prodABCDm_lhs(0)=
        prodABCDm_lhs(1).matrix_value()*ABCDm(0).matrix_value();
    }

  // Find differentials with respect to s of the modules
  Cell dABCDmds10(1,Ns);
  Cell dABCDmds11(1,Ns);
  Cell dABCDmds20(1,Ns);
  Cell dABCDmds00(1,Ns);
  Matrix zerosNsp2(Ns+2,Ns+2);
  memset(zerosNsp2.fortran_vec(),0,zerosNsp2.byte_size());
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix dABCDmds_tmp(zerosNsp2);

      dABCDmds_tmp(l+2,l+2)=1;
      dABCDmds10(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+2,l+2)=0;

      dABCDmds_tmp(l+2,l+1)=1;
      dABCDmds11(l)=dABCDmds_tmp;
      dABCDmds_tmp(l+2,l+1)=0;

      dABCDmds_tmp(l,l)=-1;
      dABCDmds_tmp(l+1,l+2)=1;
      dABCDmds20(l)=dABCDmds_tmp;
      dABCDmds_tmp(l,l)=0;
      dABCDmds_tmp(l+1,l+2)=0;
      
      dABCDmds_tmp(l,l+2)=1;
      dABCDmds_tmp(l+1,l)=1;
      dABCDmds00(l)=dABCDmds_tmp;
      dABCDmds_tmp(l,l+2)=0;
      dABCDmds_tmp(l+1,l)=0;
    }
  
  // Find differentials with respect to s of [A,B;C,D]
  Cell dABCDds10(1,Ns);
  Cell dABCDds11(1,Ns);
  Cell dABCDds20(1,Ns);
  Cell dABCDds00(1,Ns);
  if (Ns==1)
    {
      dABCDds10(0)=dABCDmds10(0).matrix_value()*ABCD0;
      dABCDds11(0)=dABCDmds11(0).matrix_value()*ABCD0;
      dABCDds20(0)=dABCDmds20(0).matrix_value()*ABCD0;
      dABCDds00(0)=dABCDmds00(0).matrix_value()*ABCD0;
    }
  else
    {
      dABCDds10(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds10(0).matrix_value()*ABCD0;
      dABCDds11(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds11(0).matrix_value()*ABCD0;
      dABCDds20(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds20(0).matrix_value()*ABCD0;
      dABCDds00(0)=
        prodABCDm_lhs(1).matrix_value()*dABCDmds00(0).matrix_value()*ABCD0;
  
      for (octave_idx_type l=1;l<(Ns-1);l++)
        {
          dABCDds10(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds10(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds11(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds11(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds20(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds20(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
          dABCDds00(l)=prodABCDm_lhs(l+1).matrix_value()
            *dABCDmds00(l).matrix_value()*prodABCDm_rhs(l-1).matrix_value();
        }   
      dABCDds10(Ns-1)=
        dABCDmds10(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds11(Ns-1)=
        dABCDmds11(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds20(Ns-1)=
        dABCDmds20(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
      dABCDds00(Ns-1)=
        dABCDmds00(Ns-1).matrix_value()*prodABCDm_rhs(Ns-2).matrix_value();
    }
  
  // Make the gradient matrixes for the s coefficients
  for (octave_idx_type l=0;l<Ns;l++)
    {
      Matrix dAds_tmp(Ns,Ns);
      ColumnVector dBds_tmp(Ns);
      RowVector dCds_tmp(Ns);
      RowVector dCapds_tmp(Ns);
      double dDds_tmp;
      double dDapds_tmp;

      // s10
      Matrix dABCDds10_tmp(dABCDds10(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds10_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds10_tmp(m,Ns);
          dCds_tmp(m)=dABCDds10_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds10_tmp(Ns,m);
        }
      dDds_tmp=dABCDds10_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds10_tmp(Ns,Ns);
      // Set the output cell values for the s10 coefficients
      dAds((l*4)+0)=dAds_tmp;
      dBds((l*4)+0)=dBds_tmp;
      dCds((l*4)+0)=dCds_tmp;
      dDds((l*4)+0)=dDds_tmp;
      dCapds((l*4)+0)=dCapds_tmp;
      dDapds((l*4)+0)=dDapds_tmp;

      // s11
      Matrix dABCDds11_tmp(dABCDds11(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds11_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds11_tmp(m,Ns);
          dCds_tmp(m)=dABCDds11_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds11_tmp(Ns,m);
        }
      dDds_tmp=dABCDds11_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds11_tmp(Ns,Ns);
      // Set the output cell values for the s11 coefficients
      dAds((l*4)+1)=dAds_tmp;
      dBds((l*4)+1)=dBds_tmp;
      dCds((l*4)+1)=dCds_tmp;
      dDds((l*4)+1)=dDds_tmp;
      dCapds((l*4)+1)=dCapds_tmp;
      dDapds((l*4)+1)=dDapds_tmp;

      // s20
      Matrix dABCDds20_tmp(dABCDds20(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds20_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds20_tmp(m,Ns);
          dCds_tmp(m)=dABCDds20_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds20_tmp(Ns,m);
        }
      dDds_tmp=dABCDds20_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds20_tmp(Ns,Ns);
      // Set the output cell values for the s20 coefficients
      dAds((l*4)+2)=dAds_tmp;
      dBds((l*4)+2)=dBds_tmp;
      dCds((l*4)+2)=dCds_tmp;
      dDds((l*4)+2)=dDds_tmp;
      dCapds((l*4)+2)=dCapds_tmp;
      dDapds((l*4)+2)=dDapds_tmp;

      // s00
      Matrix dABCDds00_tmp(dABCDds00(l).matrix_value());
      for (octave_idx_type m=0;m<Ns;m++)
        {
          for (octave_idx_type n=0;n<Ns;n++)
            {
              dAds_tmp(m,n)=dABCDds00_tmp(m,n);
            }
          dBds_tmp(m)=dABCDds00_tmp(m,Ns);
          dCds_tmp(m)=dABCDds00_tmp(Ns+1,m);
          dCapds_tmp(m)=dABCDds00_tmp(Ns,m);
        }
      dDds_tmp=dABCDds00_tmp(Ns+1,Ns);
      dDapds_tmp=dABCDds00_tmp(Ns,Ns);
      // Set the output cell values for the s00 coefficients
      dAds((l*4)+3)=dAds_tmp;
      dBds((l*4)+3)=dBds_tmp;
      dCds((l*4)+3)=dCds_tmp;
      dDds((l*4)+3)=dDds_tmp;
      dCapds((l*4)+3)=dCapds_tmp;
      dDapds((l*4)+3)=dDapds_tmp;
    }
}
