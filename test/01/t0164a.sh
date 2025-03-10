#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="test/iir_socp_slb_bandpass_test.m test_common.m delayz.m \
../tarczynski_bandpass_test_x_coef.m \
print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m x2tf.m xConstraints.m \
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
cat > test.ok << 'EOF'
Ud1=2,Vd1=0,Md1=18,Qd1=10,Rd1=2
d1 = [   0.0189068439, ...
        -0.2550677149,   0.8026098317, ...
         0.9896659144,   0.9928948767,   0.9932682145,   0.9959532021, ... 
         0.9991992291,   1.0444000165,   1.0643550757,   1.2902588866, ... 
         1.3017427646, ...
         0.2707539494,   1.9965366659,   1.7728857750,   1.6002474463, ... 
         2.5504312119,   2.2763848464,   2.9949146789,   0.7867781878, ... 
         1.1057353974, ...
         0.6133623871,   0.6167106744,   0.6570179043,   0.7203289359, ... 
         0.7589708989, ...
         2.4178101455,   1.8725788107,   1.3265411207,   2.7422379028, ... 
         1.0292509442 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_socp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
