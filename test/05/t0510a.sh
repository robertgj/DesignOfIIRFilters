#!/bin/sh

prog=dumitrescu_MA_estimation_test.m
depends="test/dumitrescu_MA_estimation_test.m test_common.m \
directFIRsymmetricA.m print_polynomial.m minphase.m x2tf.m qroots.oct \
"

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
cat > test.hstar << 'EOF'
hstar = [   1.0000000000,   0.0503778456,   0.9741721402,   0.0378300722, ... 
            0.9811177199,   0.0392519362,   0.9405569709,   0.0343480591, ... 
            0.8524512624,   0.0417684044,   0.7929695049,  -0.0008057833, ... 
            0.7807313447,  -0.0327743060,   0.7106150196,  -0.0050169840, ... 
            0.6601250764,   0.0065235264,   0.6031011210,  -0.0040073730, ... 
            0.5624625338 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hstar"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.hstar dumitrescu_MA_estimation_test_hstar_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hstar"; fail; fi

#
# this much worked
#
pass

