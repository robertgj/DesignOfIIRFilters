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
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,  -0.4879888402,   0.3768877969,   0.1804203770, ... 
          0.0178734469,  -0.0553146230,  -0.0461274856,  -0.0070978619, ... 
          0.0280688923,   0.0254945286,   0.0136551908,   0.0052910447, ... 
          0.0013345417 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da1_coef.m parallel_allpass_delay_sqp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi

#
# this much worked
#
pass

