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
cat > test_d1z.ok << 'EOF'
Ud1z=2,Vd1z=1,Md1z=10,Qd1z=10,Rd1z=1
d1z = [   0.0024215378, ...
         -0.9276447332,   1.0000000000, ...
          0.5547073939, ...
          0.8578669566,   0.9196354716,   0.9856832115,   1.7522845383, ... 
          1.9039504059, ...
          1.2461244712,   2.3037685824,   1.9250587276,   0.8715638980, ... 
          0.2794099291, ...
          0.5505529359,   0.5610094523,   0.6375003669,   0.8064201473, ... 
          0.8651043346, ...
          0.9277014612,   0.5000625832,   1.3114675485,   1.2806778026, ... 
          1.3145601099 ]';
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

