#!/bin/sh

prog=parallel_allpass_delay_socp_slb_test.m

depends="parallel_allpass_delay_socp_slb_test.m \
../tarczynski_parallel_allpass_delay_test_Da0_coef.m \
test_common.m \
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
a1 = [   0.5319986650,   0.5401485760,   0.5617057319,   0.6189404673, ... 
         0.7260956861,   0.9257695353, ...
         2.8852377074,   2.3750447643,   1.8730508210,   1.3847486087, ... 
         0.2725214373,   0.9711489366 ]';
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

