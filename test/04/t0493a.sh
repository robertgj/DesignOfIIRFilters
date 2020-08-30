#!/bin/sh

prog=iir_socp_slb_fir_lowpass_test.m

depends="iir_socp_slb_fir_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=54,Qd1=0,Rd1=1
d1 = [  0.00176050, ...
       -1.16649311,  0.86273050, ...
        0.86274955,  0.86594558,  0.87088769,  0.88572597, ... 
        0.88887525,  0.90472801,  0.98572801,  0.98760448, ... 
        0.98809854,  0.98872572,  0.98946011,  0.98999599, ... 
        0.99040596,  0.99073888,  0.99104077,  0.99134075, ... 
        0.99167674,  0.99210418,  0.99270410,  0.99354853, ... 
        0.99364049,  0.99519200,  0.99785600,  1.00114735, ... 
        1.03663472,  1.38882554,  1.43173907, ...
        0.15038515,  0.30339305,  0.45294385,  0.60407603, ... 
        0.76684831,  0.92565235,  1.35762041,  1.45300238, ... 
        1.55879342,  1.66934636,  1.77738648,  1.88538203, ... 
        1.99356306,  2.10192554,  2.21042329,  2.31901105, ... 
        2.42763164,  2.53623738,  2.64477184,  1.27662876, ... 
        2.75318768,  2.86148599,  2.96989849,  3.07789289, ... 
        1.24428773,  0.60325291,  0.20362922 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
