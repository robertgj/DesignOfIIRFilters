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
d1 = [  0.00183851, ...
       -1.16374161,  0.86741438, ...
        0.86794029,  0.87007424,  0.87081646,  0.87271561, ... 
        0.87279406,  0.88806778,  0.93790938,  0.94529525, ... 
        0.95353382,  0.95607409,  0.96403099,  0.96949828, ... 
        0.97335195,  0.97615667,  0.97827229,  0.97992797, ... 
        0.98129199,  0.98250069,  0.98369363,  0.98449733, ... 
        0.98507458,  0.98695650,  0.98986785,  0.99331319, ... 
        0.99866275,  1.33714281,  1.35104526, ...
        0.47289025,  0.31206720,  0.15947848,  0.78063678, ... 
        0.62941578,  0.94160146,  1.49199731,  1.59212830, ... 
        1.40442980,  1.70032378,  1.80330111,  1.90661195, ... 
        2.01087499,  2.11604038,  2.22192837,  2.32836587, ... 
        2.43519154,  2.54227325,  2.64948570,  1.32286715, ... 
        2.75673309,  2.86397589,  2.97139021,  3.07844211, ... 
        1.26478671,  0.66461325,  0.22194853 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
