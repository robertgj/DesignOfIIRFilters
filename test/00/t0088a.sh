#!/bin/sh

prog=parallel_allpass_delay_socp_mmse_test.m

depends="parallel_allpass_delay_socp_mmse_test.m test_common.m \
parallel_allpass_delay_socp_mmse.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delayAsq.m parallel_allpass_delayT.m \
allpassP.m allpassT.m aConstraints.m a2tf.m tf2a.m \
print_polynomial.m print_pole_zero.m SeDuMi_1_3/"
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
Ua1=0,Va1=2,Ma1=0,Qa1=10,Ra1=1
a1 = [   1.0000000000, ...
         0.6844231531,  -0.5792594850, ...
         0.9478198442,   0.7037924800,   0.6881451826,   0.6419182854, ... 
         0.6075244108, ...
         1.1287356068,   0.5883634880,   1.5783418400,   2.1160842902, ... 
         2.6557410513 ]';
EOF
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,  -0.3363182477,   0.4896471644,   0.2375607963, ... 
          0.0318383390,  -0.0583425984,  -0.0461433722,   0.0000589213, ... 
          0.0266548781,   0.0156349361,  -0.0034996590,  -0.0196632453, ... 
         -0.0127053254 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m parallel_allpass_delay_socp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi

#
# this much worked
#
pass

