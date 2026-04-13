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
x2 = [   0.0284399587, ...
        -0.9716698790,   1.0218415125, ...
         0.9822899719,   0.9919811968,   0.9947698624,   0.9991776797, ... 
         0.9996509813,   0.9998521994,   0.9999185820,   1.0007483196, ... 
         1.0059934783, ...
         1.5423384367,   0.3557317198,   1.0500799843,   1.4185667107, ... 
         0.4636932980,   1.0927203661,   0.6347539859,   0.6583084820, ... 
         0.8208878239, ...
         0.9210013188,   0.9465524747,   0.9554100629,   0.9632483746, ... 
         0.9802903618,   0.9886076898,   0.9999000000,   0.9999000000, ... 
         0.9999000000,   0.9999000000, ...
         1.2357877442,   1.3790857626,   0.5612565424,   0.4893151797, ... 
         1.1144592145,   0.6244668512,   0.6319407659,   0.4682581346, ... 
         1.0966741332,   1.4119612965 ]';
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

