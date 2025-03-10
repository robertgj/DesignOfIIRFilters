#!/bin/sh

prog=iir_sqp_slb_lowpass_differentiator_alternate_test.m

depends="test/iir_sqp_slb_lowpass_differentiator_alternate_test.m \
../tarczynski_lowpass_differentiator_alternate_test_N0_coef.m \
../tarczynski_lowpass_differentiator_alternate_test_D0_coef.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_exchange_constraints.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m \
iirT.m iirP.m invSVD.m local_max.m showZPplot.m \
sqp_bfgs.m zp2x.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m \
qroots.oct"

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
cat > test_d1z.ok << 'EOF'
Ud1z=2,Vd1z=1,Md1z=10,Qd1z=10,Rd1z=1
d1z = [   0.0025732860, ...
         -0.8494672355,   1.0000000000, ...
          0.5494930791, ...
          0.7803007145,   0.8854904051,   0.9862671716,   1.7476315773, ... 
          1.8828041046, ...
          1.2374000063,   2.3148868199,   1.9297205874,   0.8759301126, ... 
          0.2848761991, ...
          0.5242516809,   0.5314903168,   0.5517636610,   0.7710371586, ... 
          0.8939130715, ...
          1.2235507523,   0.9695692544,   0.5184539970,   1.1811361018, ... 
          1.3624978769 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1z.ok iir_sqp_slb_lowpass_differentiator_alternate_test_d1z_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1z.ok"; fail; fi


#
# this much worked
#
pass

