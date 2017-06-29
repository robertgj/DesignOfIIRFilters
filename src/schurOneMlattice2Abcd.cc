// schurOneMlattice2Abcd.cc
//
// [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc] = ...
//   schurOneMlattice2Abcd(k,epsilon,p,c)
// Find the state variable matrixes and gradients for a Schur one-multiplier
// lattice filter.
// Inputs:
//  k       - the lattice filter one-multiplier coefficients
//  epsilon - the sign coefficients for each module
//  p       - the state scaling factors
//  c       - the numerator polynomial tap weights in the orthogonal basis
// Outputs:
//  [A,B;C,D]               - state variable description of the lattice filter
//  Cap,Dap                 - corresponding matrixes for the all-pass filter
//  dAdkc,dBdkc,dCdkc,dDdkc - cell vectors of the differentials of A, B, C and D
//  dCapdk,dDapdk           - cell vectors of the differentials of Cap and Dap


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

#include <cstring>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(schurOneMlattice2Abcd, args, nargout,
"[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc] = ...\n\
  schurOneMlattice2Abcd(k,epsilon,p,c)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin<4) || (nargout>12))
    {
      print_usage();
      return octave_value_list();
     }

  // Input arguments
  RowVector k = args(0).row_vector_value();
  RowVector epsilon = args(1).row_vector_value();
  RowVector p = args(2).row_vector_value();
  RowVector c = args(3).row_vector_value();
  octave_idx_type Nk=k.numel();
  octave_idx_type Nc=c.numel();
  octave_idx_type Nkc=Nk+Nc;
  if ((Nk!=epsilon.numel()) || (Nk!=p.numel()) || ((Nk+1) != c.numel()))
    {
      error("Input vector lengths inconsistent!");
      return octave_value_list();
    }

  //
  // Calculate the state variable matrixes
  //
  
  // Outputs
  Matrix A(Nk,Nk);
  ColumnVector B(Nk);
  RowVector C(Nk);
  double D;
  RowVector Cap(Nk);
  double Dap;
  
  // Modules 1 to Nk
  Matrix eyeNkp1(Nk+1,Nk+1);
  memset(eyeNkp1.fortran_vec(),0,eyeNkp1.byte_size());
  for (octave_idx_type l=0;l<Nk+1;l++)
    {
      eyeNkp1(l,l)=1;
    }
  Matrix ABCapDap(eyeNkp1);
  for (octave_idx_type l=0;l<Nk;l++)
    {
      Matrix ABCapDapm(eyeNkp1);
      ABCapDapm(l,l)=-k(l);
      ABCapDapm(l,l+1)=1+(k(l)*epsilon(l));
      ABCapDapm(l+1,l)=1-(k(l)*epsilon(l));
      ABCapDapm(l+1,l+1)=k(l);
      ABCapDap=ABCapDapm*ABCapDap;
    }
  
  // Extract state variable description
  for (octave_idx_type l=0;l<Nk;l++)
    {
      for (octave_idx_type m=0;m<Nk;m++)
        {
          A(l,m)=ABCapDap(l,m);
        }
      B(l)=ABCapDap(l,Nk);
      C(l)=c(l);
      Cap(l)=ABCapDap(Nk,l);
    }
  D=c(Nk);
  Dap=ABCapDap(Nk,Nk);

  // Scale the states
  Matrix T(Nk,Nk);
  memset(T.fortran_vec(),0,T.byte_size());
  Matrix invT(T);
  for (octave_idx_type l=0;l<Nk;l++)
    {
      T(l,l)=p(l);
      invT(l,l)=1/p(l);
    }
  A=invT*A*T;
  B=invT*B;
  C=C*T;
  Cap=Cap*T;

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
  // Calculate the differentials of A,B,C,D,Cap and Dap with respect to [k,c]
  //
  
  // Find modules 1 to Nk (again!)
  Cell ABCapDapm(1,Nk);
  for (octave_idx_type l=0;l<Nk;l++)
    {
      Matrix ABCapDapm_tmp(eyeNkp1);
      ABCapDapm_tmp(l,l)=-k(l);
      ABCapDapm_tmp(l,l+1)=1+(k(l)*epsilon(l));
      ABCapDapm_tmp(l+1,l)=1-(k(l)*epsilon(l));
      ABCapDapm_tmp(l+1,l+1)=k(l);
      ABCapDapm(l)=ABCapDapm_tmp;
    }

  // Find RHS cumulative product of the modules
  // (Octave index order is 1,2*1,...,(Nk-1)*...*1,Nk*...*1)
  Cell prodABCapDapm_rhs(1,Nk);
  prodABCapDapm_rhs(0)=ABCapDapm(0).matrix_value();
  for (octave_idx_type l=1;l<Nk;l++)
    {
      prodABCapDapm_rhs(l)=
        ABCapDapm(l).matrix_value()*prodABCapDapm_rhs(l-1).matrix_value();
    }

  // Find LHS cumulative product of the modules
  // (Octave index order is Nk*..*1,Nk*..*2,..,Nk*(Nk-1),Nk)
  Cell prodABCapDapm_lhs(1,Nk);
  if (Nk<2)
    {
      prodABCapDapm_lhs(0)=ABCapDapm(0).matrix_value();
    }
  else
    {
      prodABCapDapm_lhs(Nk-1)=ABCapDapm(Nk-1).matrix_value();
      for (octave_idx_type l=(Nk-2);l>=1;l=l-1)
        {
          prodABCapDapm_lhs(l)=
            prodABCapDapm_lhs(l+1).matrix_value()*ABCapDapm(l).matrix_value();
        }
      prodABCapDapm_lhs(0)=
        prodABCapDapm_lhs(1).matrix_value()*ABCapDapm(0).matrix_value();
    }
  // Find differentials with respect to k of the modules
  Cell dABCapDapmdk(1,Nk);
  for (octave_idx_type l=0;l<Nk;l++)
    {
      Matrix dABCapDapmdk_tmp(Nk+1,Nk+1);
      memset(dABCapDapmdk_tmp.fortran_vec(),0,dABCapDapmdk_tmp.byte_size());
      dABCapDapmdk_tmp(l,l)=-1;
      dABCapDapmdk_tmp(l,l+1)=epsilon(l);
      dABCapDapmdk_tmp(l+1,l)=-epsilon(l);
      dABCapDapmdk_tmp(l+1,l+1)=1;
      dABCapDapmdk(l)=dABCapDapmdk_tmp;
    }
  
  // Find differentials with respect to k of [A,B;Cap,Dap]
  Cell dABCapDapdk(1,Nk);
  if (Nk<2)
    {
      dABCapDapdk(0)=dABCapDapmdk(0).matrix_value();
    }
  else
    {
      dABCapDapdk(0)=
        prodABCapDapm_lhs(1).matrix_value()*dABCapDapmdk(0).matrix_value();
      for (octave_idx_type l=1;l<(Nk-1);l++)
        {
          dABCapDapdk(l)=
            prodABCapDapm_lhs(l+1).matrix_value()
            *dABCapDapmdk(l).matrix_value()
            *prodABCapDapm_rhs(l-1).matrix_value();
        }
      dABCapDapdk(Nk-1)=
        dABCapDapmdk(Nk-1).matrix_value()*prodABCapDapm_rhs(Nk-2).matrix_value();
    }
  // Allocate cell arrays for the gradients
  Cell dAdkc(1,Nkc);
  Cell dBdkc(1,Nkc);
  Cell dCdkc(1,Nkc);
  Cell dDdkc(1,Nkc);
  Cell dCapdkc(1,Nkc);
  Cell dDapdkc(1,Nkc);

  // Make the gradient matrixes for the k coefficients
  for (octave_idx_type l=0;l<Nk;l++)
    {
      Matrix dABCapDapdk_tmp(dABCapDapdk(l).matrix_value());
      Matrix dAdkc_tmp(Nk,Nk);
      ColumnVector dBdkc_tmp(Nk);
      RowVector dCdkc_tmp(Nk);
      RowVector dCapdkc_tmp(Nk);
      double dDdkc_tmp;
      double dDapdkc_tmp;
      for (octave_idx_type m=0;m<Nk;m++)
        {
          for (octave_idx_type n=0;n<Nk;n++)
            {
              dAdkc_tmp(m,n)=dABCapDapdk_tmp(m,n);
            }
          dBdkc_tmp(m)=dABCapDapdk_tmp(m,Nk);
          dCapdkc_tmp(m)=dABCapDapdk_tmp(Nk,m);
        }
      dDapdkc_tmp=dABCapDapdk_tmp(Nk,Nk);
      memset(dCdkc_tmp.fortran_vec(),0,dCdkc_tmp.byte_size());
      dDdkc_tmp=0;
      // Scale the states
      dAdkc_tmp=invT*dAdkc_tmp*T;
      dBdkc_tmp=invT*dBdkc_tmp;
      dCapdkc_tmp=dCapdkc_tmp*T;
      
      // Set the output cell values for the k coefficients
      dAdkc(l)=dAdkc_tmp;
      dBdkc(l)=dBdkc_tmp;
      dCdkc(l)=dCdkc_tmp;
      dDdkc(l)=dDdkc_tmp;
      dCapdkc(l)=dCapdkc_tmp;
      dDapdkc(l)=dDapdkc_tmp;
    }

  // Make the gradient matrixes for the c coefficients
  for (octave_idx_type l=0;l<=Nk;l++)
    {
      Matrix dAdkc_tmp(Nk,Nk);
      ColumnVector dBdkc_tmp(Nk);
      RowVector dCdkc_tmp(Nk);
      RowVector dCapdkc_tmp(Nk);
      double dDdkc_tmp;
      double dDapdkc_tmp;

      memset(dAdkc_tmp.fortran_vec(),0,dAdkc_tmp.byte_size());
      memset(dBdkc_tmp.fortran_vec(),0,dBdkc_tmp.byte_size());
      memset(dCdkc_tmp.fortran_vec(),0,dCdkc_tmp.byte_size());
      if (l<Nk)
        {
          dCdkc_tmp(l)=p(l);
          dDdkc_tmp=0;
        }
      else
        {
          dDdkc_tmp=1;
        }
      memset(dCapdkc_tmp.fortran_vec(),0,dCapdkc_tmp.byte_size());
      dDapdkc_tmp=0;

      // Set the output cell values for the c coefficients
      dAdkc(l+Nk)=dAdkc_tmp;
      dBdkc(l+Nk)=dBdkc_tmp;
      dCdkc(l+Nk)=dCdkc_tmp;
      dDdkc(l+Nk)=dDdkc_tmp;
      dCapdkc(l+Nk)=dCapdkc_tmp;
      dDapdkc(l+Nk)=dDapdkc_tmp;      
    }
  
  // Done
  if (nargout >= 7)
    {
      retval(6)=dAdkc;
    }
  if (nargout >= 8)
    {
      retval(7)=dBdkc;
    }
  if (nargout >= 9)
    {
      retval(8)=dCdkc;
    }
  if (nargout >= 10)
    {
      retval(9)=dDdkc;
    }
  if (nargout >= 11)
    {
      retval(10)=dCapdkc;
    }
  if (nargout >= 12)
    {
      retval(11)=dDapdkc;
    }
  return retval;
}
