#!/bin/sh

prog=iir_sqp_slb_differentiator_test.m

depends="iir_sqp_slb_differentiator_test.m \
../tarczynski_differentiator_test_N0_coef.m \
../tarczynski_differentiator_test_D0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
armijo_kim.m \
fixResultNaN.m iirA.m iirE.m iirP.m \
iirT.m invSVD.m local_max.m iir_sqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m tf2x.m zp2x.m x2tf.m qroots.m qzsolve.oct"

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
d1 = [  -0.0016162011, ...
        -0.3005030574,   0.3883983198,   1.0012443469,   3.1040965374, ...
        -0.2068944644,   0.3252965382, ...
         2.8232353114,   3.0315762414, ...
         2.3507256401,   1.1574426286, ...
         0.2441638889, ...
         1.5159553695 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_differentiator_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

