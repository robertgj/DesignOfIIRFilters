#!/bin/sh

prog=print_polynomial_test.m

depends="print_polynomial_test.m test_common.m print_polynomial.m"
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
# the output should look like this
#
cat > test.ok << 'EOF'
h = [ ];
x = [     22 ];
y = [ 22 ];
y = [ 1, 2, 3, 4, ... 
      5, 6, 7, 8, ... 
      9, 10 ];
z = [ 0.5, 1, 1.5, 2, ... 
      2.5, 3, 3.5, 4, ... 
      4.5, 5 ];
N1 = [   0.0000239596,   0.0001916772,   0.0006708700,   0.0013417401, ... 
         0.0016771751,   0.0013417401,   0.0006708700,   0.0001916772, ... 
         0.0000239596 ];
X = [       -5,       -4,       -3,       -2, ... 
            -1,        0,        1,        2, ... 
             3,        4,        5 ]/10;
FAIL print_polynomial(X,"X",1);
FAIL print_polynomial(X,"X","print_polynomial_test.coef.5",1);
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok"; fail; fi

cat > test.ok.1 << 'EOF'
N1 = [   0.0000239596,   0.0001916772,   0.0006708700,   0.0013417401, ... 
         0.0016771751,   0.0013417401,   0.0006708700,   0.0001916772, ... 
         0.0000239596 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.1"; fail; fi

cat > test.ok.2 << 'EOF'
N1 = [  2.39596e-05,  1.91677e-04,  6.70870e-04,  1.34174e-03, ... 
        1.67718e-03,  1.34174e-03,  6.70870e-04,  1.91677e-04, ... 
        2.39596e-05 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.1"; fail; fi

cat > test.ok.3 << 'EOF'
X = [  -0.5000000000,  -0.4000000000,  -0.3000000000,  -0.2000000000, ... 
       -0.1000000000,   0.0000000000,   0.1000000000,   0.2000000000, ... 
        0.3000000000,   0.4000000000,   0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.3"; fail; fi

cat > test.ok.4 << 'EOF'
X = [       -5,       -4,       -3,       -2, ... 
            -1,        0,        1,        2, ... 
             3,        4,        5 ]/10;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.4"; fail; fi

cat > test.ok.5 << 'EOF'
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.5"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test.ok.1 print_polynomial_test.coef.1
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.1"; fail; fi

diff -Bb test.ok.2 print_polynomial_test.coef.2
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.2"; fail; fi

diff -Bb test.ok.3 print_polynomial_test.coef.3
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.3"; fail; fi

diff -Bb test.ok.4 print_polynomial_test.coef.4
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.4"; fail; fi

diff -Bb test.ok.5 print_polynomial_test.coef.5
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.5"; fail; fi

#
# this much worked
#
pass

