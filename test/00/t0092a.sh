#!/bin/sh

prog=parallel_allpass_delay_socp_slb_test.m

depends="test/parallel_allpass_delay_socp_slb_test.m \
../tarczynski_parallel_allpass_delay_test_Da0_coef.m \
test_common.m delayz.m \
parallel_allpass_delayAsq.m \
parallel_allpass_delayT.m \
parallel_allpass_delay_slb.m \
parallel_allpass_delay_slb_constraints_are_empty.m \
parallel_allpass_delay_slb_exchange_constraints.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delay_slb_show_constraints.m \
parallel_allpass_delay_slb_update_constraints.m \
parallel_allpass_delay_socp_mmse.m \
allpassP.m allpassT.m tf2a.m a2tf.m aConstraints.m \
print_polynomial.m print_allpass_pole.m local_max.m \
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
cat > test_a1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=12,Ra1=1
a1 = [   0.5319906138,   0.5401217711,   0.5616572268,   0.6188858927, ... 
         0.7258064758,   0.9257975567, ...
         2.8852092234,   2.3749759202,   1.8729773319,   1.3846762788, ... 
         0.2723323339,   0.9711076938 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_delay_socp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

