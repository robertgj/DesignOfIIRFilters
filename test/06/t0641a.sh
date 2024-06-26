#!/bin/sh

prog=iir_socp_slb_lowpass_differentiator_test.m

depends="test/iir_socp_slb_lowpass_differentiator_test.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_exchange_constraints.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m showZPplot.m \
zp2x.m tf2x.m x2tf.m xConstraints.m qroots.m \
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
cat > test_d1z.ok << 'EOF'
Ud1z=4,Vd1z=1,Md1z=8,Qd1z=10,Rd1z=1
d1z = [   0.0034604349, ...
         -0.7076855641,   1.0000000000,   1.6126238804,   3.3563646339, ...
         -0.0970026623, ...
          0.7672557731,   0.8980074461,   0.9882221134,   1.5675123885, ...
          2.2950838512,   1.7846086677,   1.5915405624,   0.7933423059, ...
          0.2131378909,   0.6086116571,   0.6227747136,   0.6674835167, ... 
          0.9514094362, ...
          0.6126120933,   1.1273321062,   0.4026663119,   1.2686695192, ... 
          1.4126492131 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1z.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1z.ok iir_socp_slb_lowpass_differentiator_test_d1z_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1z.ok"; fail; fi

#
# this much worked
#
pass

