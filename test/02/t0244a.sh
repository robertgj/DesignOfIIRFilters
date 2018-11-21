#!/bin/sh

prog=parallel_allpass_delay_sqp_mmse_test.m

depends="parallel_allpass_delay_sqp_mmse_test.m test_common.m \
parallel_allpass_delay_sqp_mmse.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delay_slb_constraints_are_empty.m \
parallel_allpass_delayEsq.m \
parallel_allpass_delayAsq.m \
parallel_allpass_delayT.m \
allpassP.m allpassT.m aConstraints.m a2tf.m tf2a.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m print_polynomial.m \
print_allpass_pole.m qroots.m qzsolve.oct"

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
cat > test_a1_coef.m << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=12,Ra1=1
a1 = [   0.4530596182,   0.4563452965,   0.4883578710,   0.4979061494, ... 
         0.7096204884,   0.8900735116, ...
         2.3076683543,   3.1357079838,   1.9132816152,   1.4325768089, ... 
         0.3491752908,   1.0765359243 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_sqp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

