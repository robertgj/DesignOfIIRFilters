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
Ua1=0,Va1=0,Ma1=0,Qa1=12,Ra1=1
a1 = [   1.0000000000, ...
         0.9489570320,   0.6266251668,   0.6664242957,  -0.2260451885, ... 
         0.6305836292,   0.6377391810, ...
         1.1267495826,   0.4331196637,   1.6397266374,   3.1107406557, ... 
         2.8427904101,   4.0393979498 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,  -0.3126136786,   0.5135255018,   0.2595836263, ... 
          0.0473066186,  -0.0517611137,  -0.0479051307,  -0.0027893211, ... 
          0.0271948632,   0.0258013919,   0.0103724279,  -0.0096721526, ... 
          0.0012976947 ]';
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

