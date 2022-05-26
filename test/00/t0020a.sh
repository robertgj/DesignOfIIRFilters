#!/bin/sh

prog=iir_sqp_mmse_tarczynski_ex2_test.m

depends="test/iir_sqp_mmse_tarczynski_ex2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m armijo_kim.m fixResultNaN.m iirA.m iirE.m \
iirT.m invSVD.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m x2tf.m \
xConstraints.m qroots.m qzsolve.oct"

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
cat > test.x1.ok << 'EOF'
Ux1=3,Vx1=2,Mx1=20,Qx1=0,Rx1=2
x1 = [   0.0017320719, ...
        -1.3848301093,   0.4125509029,   0.4125509029, ...
        -0.5535583491,   0.0111284883, ...
         0.5862376536,   0.8555459647,   1.2340323025,   1.3457959128, ... 
         1.3766498387,   1.3890052592,   1.3904153941,   1.5201431901, ... 
         1.5763473382,   1.5841438418, ...
         0.9389116881,   1.5229001580,   1.6851391399,   1.9749880919, ... 
         2.2541329622,   2.5431581836,   2.8379025736,   1.0191948043, ... 
         0.2063733702,   0.6493642166 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.x1.ok iir_sqp_mmse_tarczynski_ex2_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.x1.ok"; fail; fi


#
# this much worked
#
pass
