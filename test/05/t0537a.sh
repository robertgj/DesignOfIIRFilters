#!/bin/sh

prog=directFIRnonsymmetric_socp_slb_bandpass_test.m

depends="directFIRnonsymmetric_socp_slb_bandpass_test.m test_common.m \
directFIRnonsymmetric_socp_mmse.m directFIRnonsymmetricEsq.m \
directFIRnonsymmetricAsq.m directFIRnonsymmetricP.m directFIRnonsymmetricT.m \
directFIRsymmetricA.m directFIRnonsymmetric_slb.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_update_constraints.m \
hofstetterFIRsymmetric.m lagrange_interp.m xfr2tf.m \
local_max.m print_polynomial.m"

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
cat > test_h.ok << 'EOF'
h = [  -0.0037571898,   0.0004840384,  -0.0030120348,  -0.0081212147, ... 
        0.0090953381,   0.0132635625,  -0.0012602736,   0.0286501497, ... 
        0.0365211870,  -0.0335212162,  -0.0256051816,   0.0044055536, ... 
       -0.1588424347,  -0.1851099632,   0.2177188912,   0.4182534529, ... 
        0.0159576473,  -0.2894983499,  -0.1132596912,   0.0308626907, ... 
       -0.0291351122,  -0.0019219507,   0.0625524084,   0.0237938629, ... 
       -0.0009868348,   0.0174772464,   0.0007433317,  -0.0154217282, ... 
       -0.0038644990,  -0.0024180291,  -0.0067218107 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h.ok directFIRnonsymmetric_socp_slb_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h.ok"; fail; fi

#
# this much worked
#
pass

