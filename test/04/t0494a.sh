#!/bin/sh

prog=iir_sqp_slb_fir_lowpass_test.m

depends="test/iir_sqp_slb_fir_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_set_empty_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m invSVD.m \
local_max.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m zp2x.m updateWchol.m \
updateWbfgs.m x2tf.m xConstraints.m qroots.m qzsolve.oct"

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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=38,Qd1=0,Rd1=1
d1 = [   0.0027961136, ...
        -1.1398182357,   0.6185709824, ...
         0.6500709963,   0.6811989108,   0.7401082108,   0.8007546922, ... 
         0.9510367658,   0.9632301609,   0.9713171587,   0.9869726239, ... 
         0.9880135547,   0.9926003904,   0.9986529698,   1.0046772314, ... 
         1.0105245346,   1.0160126469,   1.0210692554,   1.0266568622, ... 
         1.0369882093,   1.0548345904,   1.5615537329, ...
         0.1691047353,   0.2507893644,   0.4414788838,   0.6729156423, ... 
         1.5431226747,   0.9667521173,   1.1914040185,   1.7089663068, ... 
         1.5950605521,   1.8456288841,   1.9890914269,   2.1335610990, ... 
         2.2791395486,   2.4270368561,   2.5796260775,   2.7352232637, ... 
         2.8913422365,   3.0443778324,   0.3091471950 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_sqp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
