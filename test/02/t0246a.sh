#!/bin/sh

prog=parallel_allpass_delay_sqp_slb_test.m

depends="parallel_allpass_delay_sqp_slb_test.m test_common.m \
parallel_allpass_delay_sqp_mmse.m parallel_allpass_delay_slb.m \
parallel_allpass_delay_slb_show_constraints.m \
parallel_allpass_delay_slb_exchange_constraints.m \
parallel_allpass_delay_slb_update_constraints.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delay_slb_constraints_are_empty.m \
parallel_allpass_delayEsq.m parallel_allpass_delayAsq.m \
parallel_allpass_delayT.m allpassP.m allpassT.m aConstraints.m \
a2tf.m tf2a.m local_max.m sqp_bfgs.m invSVD.m armijo_kim.m updateWbfgs.m \
print_polynomial.m print_allpass_pole.m qroots.m qzsolve.oct"

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
a1 = [   0.0374112803,   0.5862440663,   0.5951931367,   0.6316396684, ... 
         0.7139318050,   0.9111356207, ...
         1.1332587659,   2.8223937768,   2.1887846088,   1.5725179200, ... 
         0.3529652083,   1.0346906969 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_delay_sqp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

