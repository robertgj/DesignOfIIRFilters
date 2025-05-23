#!/bin/sh

prog=iir_sqp_slb_differentiator_R2_test.m

depends="test/iir_sqp_slb_differentiator_R2_test.m \
../tarczynski_differentiator_R2_test_N0_coef.m \
../tarczynski_differentiator_R2_test_D0_coef.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
armijo_kim.m \
fixResultNaN.m iirA.m iirE.m iirP.m \
iirT.m invSVD.m local_max.m iir_sqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m tf2x.m zp2x.m x2tf.m qroots.oct"

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
cat > test.ok << 'EOF'
Ud1=4,Vd1=2,Md1=4,Qd1=2,Rd1=2
d1 = [   0.0007087471, ...
        -0.2762483771,   0.3634138917,   1.0000000000,   3.7824345784, ...
        -0.0497002899,   0.1281250750, ...
         3.2208181336,   3.6327180316, ...
         2.3068350892,   1.1208563860, ...
         0.0250132888, ...
         0.3027409589 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_differentiator_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

