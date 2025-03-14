#!/bin/sh

prog=allpass_phase_socp_mmse_test.m
depends="test/allpass_phase_socp_mmse_test.m allpass_phase_socp_mmse.m \
test_common.m tf2x.m zp2x.m tf2a.m a2tf.m iirA.m iirT.m iirP.m fixResultNaN.m \
allpassP.m allpassT.m print_polynomial.m print_allpass_pole.m aConstraints.m \
qroots.oct"

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
cat > test_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=1,Qa1=2,Ra1=1
a1 = [  -0.8501587922, ...
         0.5112414460, ...
         1.7875216936 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_8_nbits_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.ok allpass_phase_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_8_nbits_cost.ok"; fail; fi

#
# this much worked
#
pass
