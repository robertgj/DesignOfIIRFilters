#!/bin/sh

prog=parallel_allpass_delay_socp_mmse_test.m

depends="parallel_allpass_delay_socp_mmse_test.m test_common.m \
parallel_allpass_delay_socp_mmse.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delayAsq.m parallel_allpass_delayT.m \
allpassP.m allpassT.m aConstraints.m a2tf.m tf2a.m \
print_polynomial.m print_allpass_pole.m \
qroots.m qzsolve.oct"

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
% All-pass single-vector representation
Va1=0,Qa1=12,Ra1=1
a1 = [   0.1460814253,   0.4735134834,   0.5829663805,   0.5902634889, ... 
         0.6328476366,   0.9495708134, ...
         0.5018758824,   3.0680169660,   2.3394892787,   0.4183831458, ... 
         1.6630434696,   1.1164280046 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

