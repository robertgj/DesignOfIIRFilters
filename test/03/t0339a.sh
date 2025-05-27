#!/bin/sh

prog=iir_socp_slb_lowpass_test.m

depends="test/iir_socp_slb_lowpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m WISEJ.m \
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
d1 = [   0.0012754579, ...
         0.4381997084, ...
         0.1417733820, ...
         0.8275663143,   0.8915324243,   0.9063226339,   0.9327915035, ... 
         0.9391218558,   0.9938920954,   1.4968710575, ...
         1.6726508998,   0.9521409881,   2.2076422639,   2.5864492539, ... 
         2.9566533102,   1.2753750747,   0.3693341940, ...
         0.2048777542,   0.3905644491,   0.6612111246,   0.7198103163, ... 
         0.8698995705,   0.8768060259,   0.9391317587, ...
         1.2764229333,   1.2115870725,   0.1466930099,   0.6595071105, ... 
         0.9308703239,   1.0696274245,   1.1128274256 ]';
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
