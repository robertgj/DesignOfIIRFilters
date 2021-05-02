#!/bin/sh

prog=Lu_remarks_examples_5_and_6_test.m
depends="Lu_remarks_examples_5_and_6_test.m \
test_common.m print_polynomial.m"

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
cat > test_x5.ok << 'EOF'
x5 = [   0.000000,  -0.000000,  -0.000000,  -0.000000, ... 
         0.000000,  -0.000000,  -0.000000,  -0.000000, ... 
         1.000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x5.ok"; fail; fi

cat > test_y5.ok << 'EOF'
y5 = [   0.500000,   0.600000,  -0.400000,   3.000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_y5.ok"; fail; fi

cat > test_x6.ok << 'EOF'
x6 = [   0.000000,   0.070618,   0.000000,   0.245487, ... 
         0.522541,   0.016588,  -0.035309,  -0.122744, ... 
        -0.035309,   0.075158,   0.261271,  -0.122744, ... 
         0.261271,   0.908254 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x6.ok"; fail; fi

cat > test_y6.ok << 'EOF'
y6 = [   1.000000,   0.300000,  -0.000000,   3.155608 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_y6.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x5.ok Lu_remarks_examples_5_and_6_test_x5_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x5.ok"; fail; fi

diff -Bb test_y5.ok Lu_remarks_examples_5_and_6_test_y5_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_y5.ok"; fail; fi

diff -Bb test_x6.ok Lu_remarks_examples_5_and_6_test_x6_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x6.ok"; fail; fi

diff -Bb test_y6.ok Lu_remarks_examples_5_and_6_test_y6_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_y6.ok"; fail; fi

#
# this much worked
#
pass

