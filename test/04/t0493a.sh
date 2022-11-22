#!/bin/sh

prog=iir_socp_slb_fir_lowpass_test.m

depends="test/iir_socp_slb_fir_lowpass_test.m \
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
d1 = [  0.00183850, ...
       -1.16373630,  0.86741439, ...
        0.86794030,  0.87007422,  0.87081645,  0.87271561, ... 
        0.87279405,  0.88806783,  0.93790891,  0.94529516, ... 
        0.95353423,  0.95607372,  0.96403101,  0.96949825, ... 
        0.97335200,  0.97615592,  0.97827153,  0.97992808, ... 
        0.98129188,  0.98250161,  0.98369124,  0.98449833, ... 
        0.98507460,  0.98696215,  0.98986563,  0.99331110, ... 
        0.99866283,  1.33714311,  1.35104591, ...
        0.47289031,  0.31206724,  0.15947847,  0.78063685, ... 
        0.62941581,  0.94160151,  1.49199847,  1.59212881, ... 
        1.40443036,  1.70032366,  1.80330121,  1.90661167, ... 
        2.01087552,  2.11603991,  2.22192878,  2.32836579, ... 
        2.43519213,  2.54227287,  2.64948515,  1.32286734, ... 
        2.75673341,  2.86397148,  2.97139551,  3.07844040, ... 
        1.26478669,  0.66461304,  0.22194839 ]';
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
