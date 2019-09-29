#!/bin/sh

prog=decimator_R2_test.m

depends="decimator_R2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m Terror.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirT.m invSVD.m local_max.m iir_sqp_mmse.m \
iir_slb.m iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m x2tf.m xInitHd.m"

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
cat > test_d1_coef.m << 'EOF'
Ud1=0,Vd1=0,Md1=10,Qd1=6,Rd1=2
d1 = [   0.0155527474, ...
         0.9955412066,   0.9957950243,   0.9966907227,   0.9984714317, ... 
         1.6366218637, ...
         2.0964339475,   1.6419383968,   2.4696489882,   2.9051522795, ... 
         0.3267131561, ...
         0.2891926495,   0.4467195457,   0.5673738344, ...
         0.1236203345,   1.2815218260,   1.8806241705 ]';
EOF

if [ $? -ne 0 ]; then echo "Failed output cat test_d1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1_coef.m decimator_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

