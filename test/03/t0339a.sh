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
tf2Abcd.m qroots.m qzsolve.oct"
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
d1 = [   0.0018149742, ...
        -0.9254923094, ...
         0.7131802039, ...
         0.4402303549,   0.9114171226,   0.9269004504,   0.9337095286, ... 
         0.9789058058,   0.9945050106,   1.4726316491, ...
         0.7930288664,   1.8710476827,   2.3231557196,   2.7353673554, ... 
         0.9624937823,   1.2844344742,   0.3621570506, ...
         0.1358704608,   0.4013657967,   0.6608333796,   0.6713811456, ... 
         0.7476041430,   0.9277459820,   0.9810566218, ...
         1.9205744095,   1.4443301172,   1.1481959960,   0.4355941393, ... 
         0.7609148036,   1.0498394197,   0.9640580838 ]';
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
