// schurOneMAPlatticeDoublyPipelined2H.cc
//
// [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx]= ...
//    schurOneMAPlatticeDoublyPipelined2H(w,A,B,C,D,dAdx))
//
// Find the complex response and partial derivatives for the state variable
// implementation of a doubly-pipelined Schur one-multiplier all-pass lattice
// filter. The outputs are intermediate results in the calculation of
// the squared-magnitude, phase and group-delay responses and partial
// derivatives. 
//
// Inputs:
//  w - column vector of angular frequencies   
//  A,B,C,D - state variable description of the lattice filter. B, C and are
//            constants.
//  dAdk - cell vector of the differentials of A with respect to k
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
// In the following, Nk is the number of filter coefficients and Nx is the
// number of filter states.
//
// For each output other than d2Hdydx, the rows correspond to frequency
// vector, w, of length Nw and the columns correspond to the coefficient
// vector, k, of length Nk. d2Hdydx is returned as a matrix of size (Nw,Nk,Nk).

// Copyright (C) 2026 Robert G. Jenssen
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

static ComplexMatrix complex_tridiagonal_inverse
  (ComplexRowVector &c,ComplexRowVector &d,ComplexRowVector &e)
{
  // Find the LU decomposition of a tridiagonal system, A=L*U:
  //  _                    _     _               _   _                    _ 
  //  |d(1) e(1)            |   |1                |  |u(1) e(1)            |
  //  |c(2) d(2)  .         |   |l(2) 1           |  |     u(2)  .         |
  //  |       .   .         | = |     l(3) 1      |  |       .   .         |
  //  |       .   .  e(n-1) |   |         .  .    |  |           .  e(n-1) |
  //  |_        c(n) d(n)  _|   |_         l(n) 1_|  |_             u(n)  _|
  //
  // Then invert L and U to find A^{-1}=U^{-1}*L^{-1}. See:
  // [1] Section 4.3,"Matrix Calculations",3rd Edn,Golub and Van Loan
  // [2] Section 9.6,"Accuracy and Stability of Numerical Algorithms",2002,Higham
  
  // Use Higham Eq. 9.19 recurrence relation
  octave_idx_type n=d.numel();
  ComplexRowVector l(n);
  ComplexRowVector u(n);
  u(0)=d(0);
  for(octave_idx_type m=1;m<n;m++)
    {
      l(m)=c(m-1)/u(m-1);
      u(m)=d(m)-(l(m)*e(m-1));
    }

  // Use Golub and Van Loan Algorithm 4.3.2 to find invL=L\eye(n)
  ComplexMatrix invL(n,n);
  invL(0,0)=1;
  for(octave_idx_type m=1;m<n;m++)
    {
      invL(m,m-1)=-l(m);
      invL(m,m)=1;
    }
  for(octave_idx_type p=0;p<n-1;p++)
    {
      for(octave_idx_type q=p+2;q<n;q++)
        {
          invL(q,p)=-invL(q-1,p)*l(q);
        }
    }

  // Use Golub and Van Loan Algorithm 4.3.3 to find invU=U\eye(n)
  ComplexMatrix invU(n,n);
  for(octave_idx_type m=0;m<n;m++)
    {
      invU(m,m)=1.0/u(m);
    }
  for(octave_idx_type p=0;p<n-1;p++)
    {
      for(octave_idx_type q=p+1;q<n;q++)
        {
          invU(p,q)=-invU(p,q-1)*e(q-1)/u(q);
        }
    }
  ComplexMatrix invA=invU*invL;
  return invA;
}
#if defined(TEST_COMPLEX_TRIDIAGONAL_INVERSE)
/*
  Compile with :
    mkoctfile -v -o complex_tridiagonal_inverse.oct -Wall -O0 -ggdb3 \
    -DTEST_COMPLEX_TRIDIAGONAL_INVERSE src/schurOneMAPlatticeDoublyPipelined2H.cc
*/
DEFUN_DLD(complex_tridiagonal_inverse, args, nargout,
          "invA=complex_tridiagonal_inverse(c,d,e)")
{
  // Sanity checks
  if ((args.length() != 3) || (nargout!=1))
    {
      print_usage();
    }

  // Input arguments
  ComplexRowVector c = args(0).complex_row_vector_value();
  ComplexRowVector d = args(1).complex_row_vector_value();
  ComplexRowVector e = args(2).complex_row_vector_value();

  // Sanity check
  if (c.numel()+1 != d.numel())
    {
      error("c.numel()+1 != d.numel()");
    }
  if (e.numel()+1 != d.numel())
    {
      error("e.numel()+1 != d.numel()");
    }

  // Call
  ComplexMatrix invA(complex_tridiagonal_inverse(c,d,e));

  // Return
  octave_value_list retval(nargout);
  retval(0)=invA;
  return retval;
}

#else

DEFUN_DLD(schurOneMAPlatticeDoublyPipelined2H, args, nargout,
"[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx]=\n\
  schurOneMAPlatticeDoublyPipelined2H(w,A,B,C,D,dAdk)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
    if ((nargin>6)
        || (nargout>8)
        || ((nargout<=2) && (nargin<5))
        || ((nargout>2) && (nargin!=6)))
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
  if (round(fmod(A.rows(),2) != 0.0))
    {
      error("A.rows() not a multiple of 2!");
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
  Cell dAdk;
  octave_idx_type Nx=A.columns();
  octave_idx_type Nk=(Nx-2)/2;
  if (nargin==6)
    {
      dAdk=args(5).cell_value();
      if (Nk != dAdk.numel())
        {
          error("Nk != dAdk.numel()");
        }
    }
  Cell d2Adydx;
  
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
                                    (nargout>=7 ? Nk : 0) ) );
  ComplexNDArray d3Hdwdydx(dim_vector ( (nargout>=8 ? Nw : 0),
                                        (nargout>=8 ? Nk : 0),
                                        (nargout>=8 ? Nk : 0) ) );


  // Initialise the tridiagonal permutation matrix
  Matrix P(Nx,Nx);
  ComplexRowVector zP(Nx-1);
  for(octave_idx_type l=0;l<Nx;l+=2)
    {
      P(l,l+1)=1;
      P(l+1,l)=1;
      zP(l)=1;
    }

  // Permute the transition matrix, A
  ComplexMatrix minusAP(Nx,Nx);
  minusAP=-A*P;

  // Initialise the tridiagonal row vectors
  ComplexRowVector c(Nx-1);
  ComplexRowVector d(Nx);
  ComplexRowVector e(Nx-1);
  d(0)=minusAP(0,0);
  for(octave_idx_type l=1;l<(Nx-1);l+=2)
    {
      c(l)=minusAP(l+1,l);
      d(l)=minusAP(l,l);
      d(l+1)=minusAP(l+1,l+1); 
      e(l)=minusAP(l,l+1);
    }
  
  // Loop over w
  for (octave_idx_type l=0;l<Nw;l++)
    {
      // Find the resolvent at w
      Complex expjw(cos(w(l)),sin(w(l)));
      ComplexRowVector zc((expjw*zP)+c);
      ComplexRowVector ze((expjw*zP)+e);
      ComplexMatrix R(Nx,Nx);
      R=complex_tridiagonal_inverse(zc,d,ze);
      R=P*R;
      
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
      
      // Find dHdk
      ComplexColumnVector RB(R*B);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          dHdk(l,m)=(CR*dAdk_m*RB);
        }
      if (nargout == 3)
        {
          continue;
        }

      // Find d2Hdwdk
      ComplexColumnVector RRB(R*RB);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          d2Hdwdk(l,m)=-jexpjw*((CRR*dAdk_m*RB)+(CR*dAdk_m*RRB));
        }
      if (nargout == 4)
        {
          continue;
        } 

      // Find diagd2Hdk2 
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          diagd2Hdk2(l,m)=Complex(2,0)*CR*dAdk_m*R*dAdk_m*RB;
        } 
      if (nargout == 5)
        {
          continue;
        }

      // Find diagd3Hdwdk2
      ComplexMatrix RR(R*R);
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          diagd3Hdwdk2(l,m)=Complex(-2,0)*jexpjw*((CRR*dAdk_m*R*dAdk_m*RB) +
                                                  (CR*dAdk_m*RR*dAdk_m*RB) +
                                                  (CR*dAdk_m*R*dAdk_m*RRB));
        } 
      if (nargout == 6)
        {
          continue;
        }

      // Find d2Hdydx
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          for (octave_idx_type n=m;n<Nk;n++)
            { 
              ComplexMatrix dAdk_n=dAdk(n).complex_matrix_value();
              d2Hdydx(l,m,n) =
                (CR*dAdk_m*R*dAdk_n*RB) +
                (CR*dAdk_n*R*dAdk_m*RB);
              d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
            }
        }
      if (nargout == 7)
        {
          continue;
        }

      // Find d3Hdwdydx
      for (octave_idx_type m=0;m<Nk;m++)
        { 
          ComplexMatrix dAdk_m=dAdk(m).complex_matrix_value();
          for (octave_idx_type n=m;n<Nk;n++)
            { 
              ComplexMatrix dAdk_n=dAdk(n).complex_matrix_value();
              d3Hdwdydx(l,m,n) = Complex(-1)*jexpjw*((CRR*dAdk_n*R*dAdk_m*RB) +
                                                     (CR*dAdk_n*RR*dAdk_m*RB) +
                                                     (CR*dAdk_n*R*dAdk_m*RRB) +
                                                     (CRR*dAdk_m*R*dAdk_n*RB) +
                                                     (CR*dAdk_m*RR*dAdk_n*RB) +
                                                     (CR*dAdk_m*R*dAdk_n*RRB));
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

#endif
