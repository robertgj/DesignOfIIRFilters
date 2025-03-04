// Abcd2tf.cc
//
// Implement Le Verrier's algorithm with the MPFR arbitrary precision
// floating-point library. Given the SISO state variable description
// [A,b;c,d], Abcd2tf returns the transfer function polynomials N(z) and D(z).
// where D(z) is the characteristic equation of A. B is a length (n+1)
// cell array of nxn matrixes in which B(k,:,:) is the k'th matrix
// coefficient of the resolvent (zI-A)^(-1). See Appendix 8A, p. 333 of 
// "Digital Signal Processing", R.A. Roberts and C.T. Mullis,
// Addison-Wesley ISBN 0-201-16350-0
//
// The Octave function file Abcd2tf.m shows the original Octave code:
//    % Use Le Verrier's algorithm to find the characteristic polynomial of A
//    % and calculate the coefficients of N at the same time
//    nA=rows(A);
//    nN=nA+1;
//    N=zeros(1,nN);
//    D=[1,zeros(1,nA)];
//    BB=eye(nA);
//    B=cell(1,nN);
//    B{1}=BB;
//    for k=1:nA
//      N(k+1)=c*BB*b;
//      D(k+1)=-trace(A*BB)/k;
//      BB=(A*BB)+(D(k+1)*eye(nA));
//      B{k+1}=BB;
//    endfor
//
//    % Complete the numerator
//    N=(d*D)+N;
//
// Compile with:
//   mkoctfile -lgmp -lmpfr Abcd2tf.cc

// Copyright (C) 2022-2025 Robert G. Jenssen
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

#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>

#include <octave/oct.h>

DEFUN_DLD(Abcd2tf, args, nargout, "[N,D,B]=Abcd2tf(A,b,c,d)")
{
  if ((args.length() != 4) || (nargout < 2))
    {
      print_usage();
      return octave_value_list();
    }

  // Input arguments
  Matrix A = args(0).array_value();  
  ColumnVector b = args(1).column_vector_value();
  RowVector c = args(2).row_vector_value();
  double d = args(3).scalar_value();
  
  // Sanity checks
  if ((A.rows()==0) || (A.columns()==0))
    {
      error("A is empty");
      return octave_value_list();
    }
  if (A.rows() != A.columns())
    {
      error("A.rows() != A.columns()");
      return octave_value_list();
    }
  if (A.rows() != b.rows())
    {
      error("A.rows() != b.rows()");
      return octave_value_list();
    }
  if (b.columns() != 1)
    {
      error("b.columns() != 1");
      return octave_value_list();
    }
  if (A.rows() != c.columns())
    {
      error("A.rows() != c.columns()");
      return octave_value_list();
    }
  if (c.rows() != 1)
    {
      error("c.rows() != 1");
      return octave_value_list();
    }

  // Output arguments
  uint64_t n = A.rows();
  RowVector N(n+1);
  RowVector D(n+1);
  Cell B(1,n+1);

  // Set precision to use
  mpfr_prec_t prec = 256;
  mpfr_set_default_prec(prec);
  
  // Allocate and initialise mpfr
  mpfr_t mA[n][n];
  for (uint64_t m=0;m<n;m++)
    {
      for (uint64_t l=0;l<n;l++)
        {
          mpfr_init_set_d(mA[l][m], A(l,m), MPFR_RNDN);
        }
    }

  mpfr_t mb[n];
  for (uint64_t l=0;l<n;l++)
    {
      mpfr_init_set_d(mb[l], b(l), MPFR_RNDN);
    } 

  mpfr_t mc[n];
  for (uint64_t m=0;m<n;m++)
    {
      mpfr_init_set_d(mc[m], c(m), MPFR_RNDN);
    }

  mpfr_t md;
  mpfr_init_set_d(md, d, MPFR_RNDN);

  mpfr_t mB[n][n];
  for (uint64_t l=0;l<n;l++)
    {
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_init_set_d(mB[l][m], 0.0, MPFR_RNDN);
        }
    }

  mpfr_t mN[n+1];
  for (uint64_t l=0;l<=n;l++)
    {
      mpfr_init_set_d(mN[l], 0.0, MPFR_RNDN);
    }
  
  mpfr_t mD[n+1];
  for (uint64_t l=0;l<=n;l++)
    {
      mpfr_init_set_d(mD[l], 0.0, MPFR_RNDN);
    }

  mpfr_t mtmp_n[n];
  for (uint64_t l=0;l<n;l++)
    {
      mpfr_init_set_d(mtmp_n[l], 0.0, MPFR_RNDN);
    }
  mpfr_t mtmp_n_n[n][n];
  for (uint64_t m=0;m<n;m++)
    {
      for (uint64_t l=0;l<n;l++)
        {
          mpfr_init_set_d(mtmp_n_n[l][m], 0.0, MPFR_RNDN);
        }
    }
  
  // Le Verrier's recursion
  for (uint64_t v=0;v<=n;v++)
    {
      if (v==0)
        {
          mpfr_set_d(mN[0], 0.0, MPFR_RNDN);
          mpfr_set_d(mD[0], 1.0, MPFR_RNDN);
          for (uint64_t m=0;m<n;m++)
            {
              mpfr_set_d(mB[m][m], 1.0, MPFR_RNDN);
            }
          Matrix Bk_tmp(n,n);
          for (uint64_t m=0;m<n;m++)
            {
              for (uint64_t l=0;l<n;l++)
                {
                  Bk_tmp(l,m)=mpfr_get_d(mB[l][m], MPFR_RNDN);
                }
            }
          B(0)=Bk_tmp;
          continue;
        }
      
      // Calculate mN[v]
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_set_d(mtmp_n[m], 0.0, MPFR_RNDN);
          for (uint64_t l=0;l<n;l++)
            {
              mpfr_fma(mtmp_n[m], mc[l], mB[l][m], mtmp_n[m], MPFR_RNDN);
            }
        }
      mpfr_set_d(mN[v], 0.0, MPFR_RNDN);
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_fma(mN[v], mtmp_n[m], mb[m], mN[v], MPFR_RNDN);
        }
      
      // Calculate mA*mB[v], store in mtmp_n_n
      for (uint64_t l=0;l<n;l++)
        {
          for (uint64_t m=0;m<n;m++)
            {
              mpfr_set_d(mtmp_n_n[l][m], 0.0, MPFR_RNDN);
              for (uint64_t k=0;k<n;k++)
                {
                  mpfr_fma(mtmp_n_n[l][m], mA[l][k], mB[k][m], mtmp_n_n[l][m],
                           MPFR_RNDN);
                }
            }
        }
      
      // Calculate mD[v]
      mpfr_set_d(mD[v], 0.0, MPFR_RNDN);
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_sub(mD[v], mD[v], mtmp_n_n[m][m], MPFR_RNDN);
        }  
      mpfr_div_ui(mD[v], mD[v], v, MPFR_RNDN);
      
      // Calculate mB[v]  
      for (uint64_t l=0;l<n;l++)
        {
          for (uint64_t m=0;m<n;m++)
            {
              mpfr_set(mB[l][m],mtmp_n_n[l][m],MPFR_RNDN);
            }
          mpfr_add(mB[l][l], mB[l][l], mD[v], MPFR_RNDN);
        }

      // Copy resolvent coefficient matrix
      Matrix Bk_tmp(n,n);
      for (uint64_t m=0;m<n;m++)
        {
          for (uint64_t l=0;l<n;l++)
            {
              Bk_tmp(l,m)=mpfr_get_d(mB[l][m], MPFR_RNDN);
            }
        }
      B(v)=Bk_tmp;
    }

  // Complete the numerator
  for (uint64_t m=0;m<=n;m++)
    {
      mpfr_fma(mN[m], md, mD[m], mN[m], MPFR_RNDN);
    }

  // Copy out
  for (uint64_t l=0;l<=n;l++)
    {
      N(l)=mpfr_get_d(mN[l], MPFR_RNDN);
      D(l)=mpfr_get_d(mD[l], MPFR_RNDN);
    }

  // Deallocate
  for (uint64_t l=0;l<n;l++)
    {
      for (uint64_t m=0;m<n;m++)
        {
          mpfr_clear(mB[l][m]);
          mpfr_clear(mA[l][m]);
          mpfr_clear(mtmp_n_n[l][m]);
        }
      mpfr_clear(mb[l]);
      mpfr_clear(mc[l]);
      mpfr_clear(mN[l]);
      mpfr_clear(mD[l]);      
      mpfr_clear(mtmp_n[l]);
    }
  mpfr_clear(md);

  // Done
  octave_value_list retval(3);
  retval(0)=N;
  retval(1)=D;
  retval(2)=B;
  return octave_value_list(retval);
}
