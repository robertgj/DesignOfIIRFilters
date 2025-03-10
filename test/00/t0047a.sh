#!/bin/sh

prog=iir_sqp_slb_minimum_phase_test.m

depends="test/iir_sqp_slb_minimum_phase_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirA.m iirE.m iirT.m iirP.m \
local_max.m iir_sqp_mmse.m iir_slb.m armijo_kim.m \
fixResultNaN.m goldensection.m quadratic.m sqp_bfgs.m updateWchol.m \
updateWbfgs.m invSVD.m xConstraints.m tf2x.m x2tf.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m qroots.oct"

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
Ud1=2,Vd1=1,Md1=8,Qd1=4,Rd1=2
d1 = [   0.0057850642, ...
        -0.9960937500,  -0.9960937500, ...
         0.2014475831, ...
         0.9960937500,   0.9960937500,   0.9960937500,   0.9960937500, ...
         2.5241208511,   1.6488814710,   1.9560345955,   2.2379621908, ...
         0.3683986482,   0.7501205808, ...
         1.3927934451,   1.8465852883 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1_coef.m iir_sqp_slb_minimum_phase_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1_coef.m"; fail; fi


#
# this much worked
#
pass

