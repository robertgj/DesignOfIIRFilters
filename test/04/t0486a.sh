#!/bin/sh

prog=iir_sqp_slb_multiband_test.m

depends="test/iir_sqp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m qroots.m \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
qzsolve.oct"

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
cat > test_x1.ok << 'EOF'
Ux1=2,Vx1=0,Mx1=18,Qx1=20,Rx1=1
x1 = [   0.0303398029, ...
        -0.8957799195,   0.8033005143, ...
         0.9664276886,   0.9760663727,   0.9868987808,   0.9941475618, ... 
         0.9980489508,   0.9987599232,   0.9995476013,   0.9998399782, ... 
         0.9999057218, ...
         1.5833118673,   0.3503882643,   0.8176843727,   1.0554868092, ... 
         0.6553343466,   1.4220852658,   0.4630527657,   1.0927535401, ... 
         0.6347457415, ...
         0.9197495728,   0.9337976415,   0.9551886518,   0.9596351478, ... 
         0.9815303427,   0.9881658792,   0.9999000000,   0.9999000000, ... 
         0.9999000000,   0.9999000000, ...
         1.2302913534,   1.3680933992,   0.5654826545,   0.4997801346, ... 
         1.1149311669,   0.6248639686,   0.4689157659,   0.6317932422, ... 
         1.0968331041,   1.4112776061 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1.ok iir_sqp_slb_multiband_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1.ok"; fail; fi

#
# this much worked
#
pass

