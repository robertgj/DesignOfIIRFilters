#!/bin/sh

prog=allpass2ndOrderCascade_socp_test.m

depends="allpass2ndOrderCascade_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascade_socp.m \
casc2tf.m tf2casc.m qroots.m qzsolve.oct"

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
cat > test_a1_coef.m << 'EOF'
a1 = [   0.7727560722,  -0.1744020889,  -0.2794180348,   0.2646264412, ... 
         0.2496664349,  -1.2063468327,   0.5003157954,  -0.6669818514, ... 
         0.4892481884,   1.3476343883,   0.4044902889 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_b1_coef.m << 'EOF'
b1 = [   0.0617316708,  -0.2935684414,  -0.9120767593,   0.8612635075, ... 
        -0.6690304067,   0.1384014921,   0.1494931975,   0.1737759823, ... 
         0.7818585585,   0.0150380843,   0.4608158727,  -0.3919497458 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascade_socp_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m allpass2ndOrderCascade_socp_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi


#
# this much worked
#
pass

