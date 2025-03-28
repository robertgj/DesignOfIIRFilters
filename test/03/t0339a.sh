#!/bin/sh

prog=iir_socp_slb_lowpass_test.m

depends="test/iir_socp_slb_lowpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m WISEJ_ND.m \
tf2Abcd.m qroots.oct"
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
cat > test.d1.ok << 'EOF'
Ud1=1,Vd1=1,Md1=14,Qd1=14,Rd1=1
d1 = [   0.0018834145, ...
        -0.9192530826, ...
         0.7129052406, ...
         0.4519467010,   0.8977739930,   0.9127694656,   0.9209086795, ... 
         0.9712856186,   1.0024006015,   1.4730313132, ...
         0.7854468543,   1.8563625283,   2.3174325127,   2.7331497836, ... 
         0.9648195607,   1.2864175291,   0.3612561811, ...
         0.1429253579,   0.4008777566,   0.6728546689,   0.6729752363, ... 
         0.7478144210,   0.9255702805,   0.9738055699, ...
         1.9230203610,   1.4526125834,   0.4303089823,   1.1420140565, ... 
         0.7533942843,   1.0418309410,   0.9685256192 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
