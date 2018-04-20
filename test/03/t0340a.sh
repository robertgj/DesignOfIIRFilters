#!/bin/sh

prog=fir_socp_slb_lowpass_test.m

depends="fir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m x2tf.m xConstraints.m SeDuMi_1_3/"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0007996422, ...
       -33.8319438027,  -0.9432662754, ...
         1.3102224704,   0.9333504875,   0.9319570250,   0.9318045141, ... 
         0.9248681068,   0.9324361350,   0.9390682242,   0.9517636792, ... 
         0.9685588138,   0.9934032883,   0.5843440371,   0.7779696303, ... 
         0.7343707827,   0.7133266569, ...
         0.3708101231,   2.9198389439,   2.7019820308,   2.4803917132, ... 
         2.2585886073,   2.0312260221,   1.8019861132,   1.5876189678, ... 
         1.4011575284,   1.2751461178,   1.9103236478,   0.4297354387, ... 
         0.8141500356,  -0.1809814789 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok fir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
