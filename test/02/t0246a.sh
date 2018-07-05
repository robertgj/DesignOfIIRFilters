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
print_polynomial.m print_pole_zero.m qroots.m qzsolve.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
#        rm -rf $tmp
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
cat > test_a1_coef.m.ok << 'EOF'
Ua1=0,Va1=0,Ma1=0,Qa1=12,Ra1=1
a1 = [   1.0000000000, ...
         0.0375606055,   0.5863234542,   0.5952557557,   0.6316735234, ... 
         0.7139472596,   0.9111338936, ...
         1.1305838168,   2.8224134044,   2.1888155504,   1.5725491276, ... 
         0.3530048158,   1.0347051569 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok parallel_allpass_delay_sqp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

