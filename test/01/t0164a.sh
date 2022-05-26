#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="test/iir_socp_slb_bandpass_test.m test_common.m \
../tarczynski_bandpass_test_x_coef.m \
print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m x2tf.m xConstraints.m \
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
cat > test.ok << 'EOF'
Ud1=2,Vd1=2,Md1=18,Qd1=8,Rd1=2
d1 = [   0.0163061564, ...
        -1.0642007959,   0.9743301667, ...
        -0.6781850251,  -0.5472992260, ...
         0.9917467397,   0.9926851198,   1.0001611212,   1.0030549524, ... 
         1.0734655894,   1.0830114950,   1.1205558252,   1.2829654040, ... 
         1.2903179219, ...
         1.9272058003,   0.2806196143,   1.7180771221,   1.5900734378, ... 
         2.4751347334,   2.1911788196,   2.6644259872,   0.7779719524, ... 
         1.1194500892, ...
         0.6035307759,   0.6143246310,   0.6319038121,   0.7281844175, ...
         1.9135840355,   1.2865743040,   2.6025854213,   1.0060693680 ]';
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
