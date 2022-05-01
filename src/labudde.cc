// labudde.cc
//
// Implement La Budde's recursion for calculating the characteristic
// polynomial of an upper Hessenberg matrix.
//
// Octave function file labbude.m shows the original Octave code. See
// Appendix B of the Ph.D. thesis of R. Rehman, "Numerical Computation
// of the Characteristic Polynomial of a Complex Matrix", downloaded
// from http://www.lib.ncsu.edu/resolver/1840.16/6262
//
// Compile with:
//   mkoctfile labudde.cc
//
// Test with address-sanitizer:
#if 0
   mkoctfile -O0 -g -fsanitize=address -fsanitize=undefined \
     -fno-sanitize=vptr -fno-omit-frame-pointer-fsanitize=address \
     -fno-omit-frame-pointer labudde.cc
   LD_PRELOAD=/usr/lib64/libasan.so.5 octave --eval "a=labudde(rand(4,4))"
#endif

// Copyright (C) 2017,2022 Robert G. Jenssen
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

#include <octave/oct.h>
#include <octave/builtin-defun-decls.h>

DEFUN_DLD(labudde, args, nargout, "a=labudde(A)")
{ 
  if ((args.length() < 1) || (nargout > 1))
    {
      print_usage();
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }
  if (args(0).rows() != args(0).columns())
    {
      warning("labudde.cc: Expected A.rows() == A.columns()");
      RowVector retval0(0);
      octave_value_list retval(1);
      retval(0)=retval0;
      return octave_value_list(retval);
    }

  // Find the upper Hessenberg form of the input matrix
  octave_value_list Harg=octave::Fhess(args(0),1);
  Matrix H = Harg(0).matrix_value();
  const uint64_t N = H.rows();
  
  // Copy H into an array of long doubles
  OCTAVE_LOCAL_BUFFER (long double, Hmem, N*N);
  OCTAVE_LOCAL_BUFFER (long double *, HH, N);
  for (uint64_t l=0;l<N;l++)
    {
      HH[l]=Hmem+(N*l);
    }
  for (uint64_t l=0;l<N;l++)
    {
      for (uint64_t m=0;m<N;m++)
        {
          HH[l][m]=H(l,m);
        }
    }

  // Storage for the characteristic polynomials of the sub-matrixes of H
  uint64_t k=N;
  OCTAVE_LOCAL_BUFFER (long double, cmem, N*k);
  OCTAVE_LOCAL_BUFFER (long double *, c, N);
  for (uint64_t l=0;l<N;l++)
    {
      c[l]=cmem+(l*k);
    }
  memset(cmem,0,N*k*sizeof(long double));
  c[0][0]=-HH[0][0];
  
  // Storage for the subdiagonal of H
  OCTAVE_LOCAL_BUFFER (long double, gamma, N);
  gamma[0]=0;
  for (uint64_t l=1;l<N;l++)
    {
      gamma[l]=HH[l][l-1];
    }

  // labudde.m main loop to determine the first k coefficients
  OCTAVE_LOCAL_BUFFER (long double, Prod, N);
  for(uint64_t m=1;m<N;m++)
    {
      for(uint64_t j=0;j<k;j++)
        {
          if (j<=m)
            {
              if (j==0)
                {
                  c[m][j]=c[m-1][j]-HH[m][m];
                }
              else
                {
                  long double Sum=0;
                  for (uint64_t l=0;l<j;l++)
                    {
                      Prod[l]=gamma[m];
                    }
                  if(j>1)
                    {
                      for (uint64_t s=0;s<j-1;s++)
                        {
                          Prod[s+1]=Prod[s]*gamma[m-s-1];
                          Sum=Sum+(HH[m-s-1][m]*Prod[s]*c[m-s-2][j-s-2]);
                        }
                      Sum=Sum+(HH[m-j][m]*Prod[j-1]);
                    }
                  if(j==1)
                    {
                      Sum=HH[m-1][m]*Prod[0];
                    }
                  c[m][j]=c[m-1][j]-(HH[m][m]*c[m-1][j-1])-Sum;
                }
            }
        }
    }
  
  // Copy the output argument
  RowVector a(k);
  for (uint64_t l=0;l<k;l++)
    {
      a(l)=c[N-1][l];
    }
  
  // Done
  octave_value_list retval(1);
  retval(0)=a;
  return octave_value_list(retval);
}
