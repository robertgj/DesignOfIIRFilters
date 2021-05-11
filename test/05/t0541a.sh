#!/bin/sh

# See: "oct-file has undefined symbol" : https://savannah.gnu.org/bugs/?60567  

prog=complex_matrix_test.m
depends=""

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
# Test scripts
#
cat > complex_matrix.m << 'EOF'
function H = complex_matrix(w,A,b,c,d)
% H = complex_matrix(w,A,b,c,d)

  warning("Using Octave m-file version of function complex_matrix()!");
  
  % Sanity checks
  if ((nargin~=5) || (nargout>1)) print_usage("H = complex_matrix(w,A,b,c,d)");
  endif
  if isempty(A)
    error("A is empty");
  endif
  if (rows(A) ~= columns(A))
    error("rows(A) ~= columns(A)");
  endif
  if (rows(A) ~= rows(b))
    error("rows(A) ~= rows(b)");
  endif
  if (columns(A) ~= columns(c))
    error("columns(A) ~= columns(c)");
  endif
  if ~isscalar(d)
    error("~isscalar(d)");
  endif

  H=zeros(size(w));
  for k=1:length(w)
    zI=exp(j*w(k))*eye(size(A));
    R=inv(zI-A);
    H(k)=(c*R*b) + d;
  endfor

endfunction
EOF
if [ $? -ne 0 ]; then echo "Failed output cat complex_matrix.m"; fail; fi

cat > complex_matrix.cc << 'EOF'
// complex_matrix.cc
//
// H=complex_matrix(w,A,b,c,d)

#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(complex_matrix, args, nargout,
"H=complex_matrix(w,A,b,c,d)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin!=5) || (nargout>1))
    {
      print_usage();
    }

  // Input arguments
  ColumnVector w = args(0).column_vector_value();
  ComplexMatrix A = args(1).complex_matrix_value();  
  ComplexColumnVector b = args(2).complex_column_vector_value();
  ComplexRowVector c = args(3).complex_row_vector_value();
  Complex d(args(4).scalar_value(),0);

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
  if (A.rows() != c.columns())
    {
      error("A.rows() != c.columns()");
    }

  // H=c*inv(exp(j*w)-A)*b+d
  octave_idx_type Nw=w.numel();
  ComplexColumnVector H(Nw);
  ComplexMatrix zIminusA(-A);
  octave_idx_type N=A.columns();
  for (octave_idx_type l=0;l<Nw;l++)
    {
      Complex expjw(cos(w(l)),sin(w(l)));
      for(octave_idx_type m=0;m<N;m++)
        {
          zIminusA(m,m)+=expjw;
        }

      octave_value_list argval(1),Rval(1);
      argval(0)=zIminusA;
      Rval=octave::feval("inv",argval,1);
      ComplexMatrix R=Rval(0).complex_matrix_value();
  
      ComplexRowVector cR(c*R);
      Complex cRb(cR*b);
      H(l)=cRb+d;
    }
                       
  // Done
  octave_value_list retval(1);
  retval(0)=H;

  return retval;
}
EOF
if [ $? -ne 0 ]; then echo "Failed output cat complex_matrix.cc"; fail; fi

cat > complex_matrix_test.m << 'EOF'
% complex_matrix_test.m

warning("off");

w = 2*pi*0.1;
A = [ 0.8090,  0.5878; ...
     -0.2426,  0.3340];
b = [      0;  0.9108];
c = [ 0.3944,  0.2328];
d = 0.067455;

exist('complex_matrix.oct','file')
H = complex_matrix(w,A,b,c,d)

EOF
if [ $? -ne 0 ]; then echo "Failed output cat complex_matrix_test.m"; fail; fi

cat > complex_matrix_test.sh << 'EOF'
#! /bin/sh 
octave --no-gui complex_matrix_test.m 
mkoctfile -v -Wall -Werror complex_matrix.cc >/dev/null 2>&1
octave --no-gui complex_matrix_test.m 
EOF
if [ $? -ne 0 ]; then echo "Failed output cat complex_matrix_test.sh"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
ans = 0
H = -3.9650e-05 - 7.0719e-01i
ans = 3
H = -3.9650e-05 - 7.0719e-01i
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

sh ./complex_matrix_test.sh > test.results 2>&1
diff -Bb test.ok test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
