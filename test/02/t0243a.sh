#!/bin/sh

prog=iir_sqp_slb_pink_test.m

depends="iir_sqp_slb_pink_test.m \
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
d1 = [   0.0008367854, ...
        -2.7692029142,   0.7592391107,   0.8792893930, ...
         0.9611516080, ...
         0.5006814668,   0.9710174489,   3.1183691633,   3.2110418531, ...
         0.0000014270,   0.0298039843,   0.6946535183,   1.8874490769, ...
         0.3346426924,   0.3483303078,   0.5109820109,   0.7590128415, ... 
         0.9687500000, ...
         2.4095991591,   1.2407314689,   0.3499618633,   0.0000000251, ... 
         0.0248997073 ]';
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

