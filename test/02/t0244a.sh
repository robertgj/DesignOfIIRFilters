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
sqp_bfgs.m armijo_kim.m updateWbfgs.m print_polynomial.m print_pole_zero.m"
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
Ua1=0,Va1=0,Ma1=0,Qa1=12,Ra1=1
a1 = [   1.0000000000, ...
         0.8900735105,   0.7096204812,   0.4979061387,   0.4883578661, ... 
         0.4563452869,   0.4530596131, ...
         1.0765359289,   0.3491752822,   1.4325768123,   1.9132816203, ... 
         3.1357079361,   2.3076683607 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,  -0.4656938338,   0.3932740898,   0.1800514545, ... 
         -0.0108345423,  -0.0456134194,  -0.0478379625,   0.0122069985, ... 
          0.0230940926,   0.0222695897,   0.0120003947,   0.0044934098, ... 
          0.0010082616 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_sqp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m parallel_allpass_delay_sqp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi

#
# this much worked
#
pass

