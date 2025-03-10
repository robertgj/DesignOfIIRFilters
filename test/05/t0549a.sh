#!/bin/sh

prog=iir_sqp_slb_lowpass_differentiator_test.m

depends="test/iir_sqp_slb_lowpass_differentiator_test.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
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
d1z = [   0.0029208619, ...
         -1.6937986362,   1.0000000000, ...
          0.5525657117, ...
          0.9423827368,   0.9782466093,   1.6683991287,   1.7648997112, ... 
          1.8037171989, ...
          2.8771749926,   2.5562722588,   1.5663222614,   0.9316075695, ... 
          0.3092072626, ...
          0.3656656406,   0.5583780473,   0.5778958636,   0.6618228078, ... 
          0.8794296474, ...
          1.9603934693,   0.6195601241,   1.2487753544,   1.8898084276, ... 
          2.2126813396 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1z.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1z.ok iir_sqp_slb_lowpass_differentiator_test_d1z_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1z.ok"; fail; fi

#
# this much worked
#
pass

