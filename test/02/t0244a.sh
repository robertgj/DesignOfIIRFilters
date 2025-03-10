#!/bin/sh

prog=parallel_allpass_delay_sqp_mmse_test.m

depends="test/parallel_allpass_delay_sqp_mmse_test.m test_common.m delayz.m \
parallel_allpass_delay_sqp_mmse.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delay_slb_constraints_are_empty.m \
parallel_allpass_delayEsq.m \
parallel_allpass_delayAsq.m \
parallel_allpass_delayT.m \
allpassP.m allpassT.m aConstraints.m a2tf.m tf2a.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m print_polynomial.m \
print_allpass_pole.m qroots.oct"

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
a1 = [   0.4454621455,   0.4616005591,   0.4728918288,   0.4836477358, ... 
         0.6863651355,   0.8860601766, ...
         3.0619063323,   2.2797253150,   1.9655282840,   1.3848265561, ... 
         0.3403275247,   1.0756414070 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_sqp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

