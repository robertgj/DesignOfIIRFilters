#!/bin/sh

prog=tuqanFIRnonsymmetric_dare_minimum_phase_test.m
depends="tuqanFIRnonsymmetric_dare_minimum_phase_test.m test_common.m \
print_polynomial.m direct_form_scale.m qroots.m qzsolve.oct"

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
cat > test.g_coef << 'EOF'
g = [   0.6892787691,  -0.1393627881,   0.0612306282,   0.1836395573, ... 
        0.1271607459,  -0.0044870685,  -0.0609609866,  -0.0256111474, ... 
        0.0069921151,  -0.0167027181,  -0.0502981787,  -0.0349598651, ... 
        0.0159697356,   0.0453437644,   0.0302585960,  -0.0003336360, ... 
       -0.0121685867,  -0.0024660115,   0.0084549716,   0.0039279399, ... 
       -0.0138442229,  -0.0260231828,  -0.0153546156,   0.0109558709, ... 
        0.0234266291,   0.0077636213,  -0.0085846329,   0.0092554926, ... 
        0.0439405825,   0.0341121099,  -0.0403486959 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.g_coef"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.g_coef tuqanFIRnonsymmetric_dare_minimum_phase_test_g_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.g_coef"; fail; fi

#
# this much worked
#
pass

