#!/bin/sh

prog=print_polynomial_test.m

depends="print_polynomial_test.m test_common.m print_polynomial.m"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
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

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.1 print_polynomial_test.coef.1
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi
diff -Bb test.ok.2 print_polynomial_test.coef.2
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

