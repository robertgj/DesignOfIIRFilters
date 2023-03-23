#!/bin/sh

prog=parallel_allpass_delay_sqp_slb_test.m

depends="test/parallel_allpass_delay_sqp_slb_test.m \
../tarczynski_parallel_allpass_delay_test_Da0_coef.m \
test_common.m parallel_allpass_delay_sqp_mmse.m parallel_allpass_delay_slb.m \
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
a1 = [   0.0432927711,   0.4494672980,   0.5533258192,   0.6224931183, ... 
         0.6890110077,   0.9063398941, ...
         0.7873737992,   2.9870134705,   2.3416065987,   1.6538439029, ... 
         0.3604129871,   1.0533527126 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_delay_sqp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

