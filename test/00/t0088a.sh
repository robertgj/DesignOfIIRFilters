#!/bin/sh

prog=parallel_allpass_delay_socp_mmse_test.m

depends="parallel_allpass_delay_socp_mmse_test.m test_common.m \
parallel_allpass_delay_socp_mmse.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delayAsq.m parallel_allpass_delayT.m \
allpassP.m allpassT.m aConstraints.m a2tf.m tf2a.m \
print_polynomial.m print_pole_zero.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
         0.1516439388,   0.4750154527,   0.5841336535,   0.5886150299, ... 
         0.6335031691,   0.9495327988, ...
         0.5010126706,   3.0658621836,   2.3399870621,   0.4191886532, ... 
         1.6640460456,   1.1166559072 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_delay_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

