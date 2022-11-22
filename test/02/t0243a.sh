#!/bin/sh

prog=iir_sqp_slb_pink_test.m

depends="test/iir_sqp_slb_pink_test.m \
../tarczynski_pink_test_D0_coef.m \
../tarczynski_pink_test_N0_coef.m \
test_common.m print_polynomial.m \
print_pole_zero.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m xConstraints.m tf2x.m zp2x.m x2tf.m \
qroots.m qzsolve.oct"

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
Ud1=3,Vd1=1,Md1=8,Qd1=10,Rd1=1
d1 = [   0.0008367782, ...
        -2.7692064508,   0.7592510023,   0.8792899106, ...
         0.9611520680, ...
         0.5006846218,   0.9710175589,   3.1183742858,   3.2110483158, ...
         0.0000004818,   0.0298043425,   0.6946538144,   1.8874489538, ...
         0.3346420416,   0.3483295392,   0.5109831976,   0.7590192743, ... 
         0.9687500000, ...
         2.4095982427,   1.2407296753,   0.3499580427,   0.0000002864, ... 
         0.0249003058 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_pink_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

