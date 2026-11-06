#!/bin/sh

prog=iir_sqp_slb_multiband_test.m

depends="test/iir_sqp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m qroots.oct \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
"

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
cat > test_x2.ok << 'EOF'
Ux2=2,Vx2=0,Mx2=18,Qx2=20,Rx2=1
x2 = [   0.0284399611, ...
        -0.9716698445,   1.0218413942, ...
         0.9822899688,   0.9919812175,   0.9947698658,   0.9991776797, ... 
         0.9996509813,   0.9998521993,   0.9999185820,   1.0007483247, ... 
         1.0059934623, ...
         1.5423384368,   0.3557317275,   1.0500799800,   1.4185667107, ... 
         0.4636932981,   1.0927203661,   0.6347539858,   0.6583084803, ... 
         0.8208878445, ...
         0.9210013190,   0.9465524745,   0.9554100626,   0.9632483748, ... 
         0.9802903618,   0.9886076899,   0.9999000000,   0.9999000000, ... 
         0.9999000000,   0.9999000000, ...
         1.2357877450,   1.3790857621,   0.5612565423,   0.4893151785, ... 
         1.1144592144,   0.6244668523,   0.4682581346,   0.6319407661, ... 
         1.0966741331,   1.4119612965 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x2.ok iir_sqp_slb_multiband_test_x2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

#
# this much worked
#
pass

