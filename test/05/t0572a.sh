#!/bin/sh

prog=Abcd2tf_test.m

depends="test/Abcd2tf_test.m test_common.m tf2schurOneMlattice.m \
check_octave_file.m print_polynomial.m KW.m optKW.m schurOneMscale.m tf2Abcd.m \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# Source for the octfile
#
cat > Abcd2tf_eigen.cc << 'EOF'
// Abcd2tf_eigen.cc
//
// [N,D,B] = Abcd2tf_eigen(A,b,c,d)
// C++ implementation of Abcd2tf.m with the Eigen C++ template library.
// Use Le Verrier's algorithm to find the transfer function
// H(z)=[N(z)/D(z)]=c*[(zI-A)^{-1}]*b+d where[A,b;c,d] is the real-valued
// single-input and single-output state variable description. D(z) is the
// characteristic equation of A and B is a length (n=rows(A))+1 cell array
// of nxn matrixes in which B{k} is the k'th matrix coefficient of the
// resolvent (zI-A)^{-1}.
//
// See Appendix 8A, pp. 332-333 of "Digital Signal Processing", R.A. Roberts
// and C.T. Mullis, Addison-Wesley ISBN 0-201-16350-0
//
// This oct-file uses the eigen template library: https://eigen.tuxfamily.org
// eigen is used with long double in an attempt to improve accuracy for
// large sizes of A. I initialise explicitly with loops to avoid worrying about
// column-major or row-major ordering.

// Copyright (C) 2024 Robert G. Jenssen
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
#include <Eigen/Eigen>

typedef long double AbcdReal;
typedef Eigen::Matrix<AbcdReal,Eigen::Dynamic,1> AbcdRealColumnVector;
typedef Eigen::Matrix<AbcdReal,1,Eigen::Dynamic> AbcdRealRowVector;
typedef Eigen::Matrix<AbcdReal,Eigen::Dynamic,Eigen::Dynamic>AbcdRealMatrix;

DEFUN_DLD(Abcd2tf_eigen, args, nargout,"[N,D,B] = Abcd2tf_eigen(A,b,c,d)")
{

  // Sanity checks
  octave_idx_type nargin=args.length();
  if((nargin!=4) || ((nargout !=2) && (nargout != 3)))
    {
      print_usage();
    }

  // Octave input variables
  Matrix A = args(0).matrix_value();  
  ColumnVector b = args(1).column_vector_value();
  RowVector c = args(2).row_vector_value();
  double d = args(3).scalar_value();
  // Sanity checks
  if ((A.rows()==0) || (A.columns()==0))
    {
      error("A is empty");
    }
  if (A.rows() != A.columns())
    {
      error("A.rows() != A.columns()");
    }
  if (A.rows() != b.rows())
    {
      error("A.rows() != b.rows()");
    }
  if (b.columns() != 1)
    {
      error("b.columns() != 1");
    }
  if (A.rows() != c.columns())
    {
      error("A.rows() != c.columns()");
    }
  if (c.rows() != 1)
    {
      error("c.rows() != 1");
    }

  // Declare the Octave output variables
  octave_idx_type nA=A.rows();
  octave_idx_type nN=1+nA;
  RowVector N(nN);
  RowVector D(nN);
  Cell B(1,nN);

  // Initialise the AbcdReal local variables
  AbcdRealMatrix eye_nA(nA,nA);
  eye_nA.setZero();
  for(auto l=0;l<nA;l++)
    {   
      eye_nA(l,l)=1;
    }
  AbcdRealMatrix AA(nA,nA);
  for(auto m=0;m<nA;m++)
    {
      for(auto l=0;l<nA;l++)
        {
          AA(l,m)=A(l,m);
        }
    }
  AbcdRealColumnVector bb(nA);
  for(auto l=0;l<nA;l++)
    {
      bb(l)=b(l);
    }
  AbcdRealRowVector cc(nA);
  for(auto m=0;m<nA;m++)
    {
      cc(m)=c(m);
    }
  AbcdReal dd=d;
  
  // Initialise the local AbcdReal versions of the output N, D and B variables
  AbcdRealRowVector DD(nN);
  AbcdRealRowVector NN(nN);
  DD(0)=1;
  NN(0)=0;
  AbcdRealMatrix BB(nA,nA);
  BB=eye_nA;
  {
    Matrix T(nA,nA);
    for(auto m=0;m<nA;m++)
      {
        for(auto l=0;l<nA;l++)
          {
            T(l,m)=(double)BB(l,m);
          }
      }
    B(0)=T;
  }

  // Do the loop over the characteristic polynomial
  for(auto k=1;k<nN;k++)
    {
      NN(k)=cc*BB*bb;
      AbcdRealMatrix AABB(nA,nA);
      AABB=AA*BB;
      DD(k)=-AABB.trace()/k;
      BB=(AA*BB)+(DD(k)*eye_nA);

      // Copy BB to the output cell variable B(k)
      Matrix T(nA,nA);
      for(auto m=0;m<nA;m++)
        {
          for(auto l=0;l<nA;l++)
            {
              T(l,m)=(double)BB(l,m);
            }
        }
      B(k)=T;
    }

  // Finalise NN
  NN=(dd*DD)+NN;

  // Copy the NN and DD output variables
  for(auto k=0;k<nN;k++)
    {
      N(k)=(double)NN(k);
      D(k)=(double)DD(k);
    }
  
  // Done
  octave_value_list retval(nargout);
  retval(0)=N;
  retval(1)=D;
  if (nargout == 3)
    {
      retval(2)=B;
    }
  return retval;
}
EOF
if [ $? -ne 0 ]; then echo "Failed Abcd2tf.cc cat"; fail; fi

mkoctfile -o Abcd2tf_eigen.oct -lgmp -I/usr/include/eigen3 Abcd2tf_eigen.cc 
if [ $? -ne 0 ]; then echo "Failed mkoctfile"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
Using Abcd2tf_eigen octfile
Invalid call to Abcd2tf_eigen.  Correct usage is:

[N,D,B] = Abcd2tf_eigen(A,b,c,d)
Invalid call to Abcd2tf_eigen.  Correct usage is:

[N,D,B] = Abcd2tf_eigen(A,b,c,d)
Invalid call to Abcd2tf_eigen.  Correct usage is:

[N,D,B] = Abcd2tf_eigen(A,b,c,d)
Invalid call to Abcd2tf_eigen.  Correct usage is:

[N,D,B] = Abcd2tf_eigen(A,b,c,d)
A is empty
A.rows() != A.columns()
A.rows() != b.rows()
A.rows() != b.rows()
A.rows() != c.columns()
A.rows() != c.columns()
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

