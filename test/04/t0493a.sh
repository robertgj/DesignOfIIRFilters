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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=54,Qd1=0,Rd1=1
d1 = [  0.00183851, ...
       -1.16375367,  0.86741437, ...
        0.86794029,  0.87007425,  0.87081647,  0.87271561, ... 
        0.87279406,  0.88806776,  0.93790961,  0.94529558, ... 
        0.95353364,  0.95607416,  0.96403104,  0.96949830, ... 
        0.97335289,  0.97615646,  0.97827342,  0.97992782, ... 
        0.98129299,  0.98250025,  0.98369255,  0.98449693, ... 
        0.98507720,  0.98696056,  0.98985802,  0.99330972, ... 
        0.99866271,  1.33714268,  1.35104497, ...
        0.47289024,  0.31206718,  0.15947848,  0.78063676, ... 
        0.62941577,  0.94160145,  1.49199695,  1.59212812, ... 
        1.40442956,  1.70032392,  1.80330118,  1.90661147, ... 
        2.01087537,  2.11604013,  2.22192865,  2.32836600, ... 
        2.43519147,  2.54227351,  2.64948657,  1.32286706, ... 
        2.75673137,  2.86397120,  2.97139421,  3.07844502, ... 
        1.26478672,  0.66461333,  0.22194857 ]';
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
