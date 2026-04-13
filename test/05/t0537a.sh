#!/bin/sh

prog=directFIRnonsymmetric_socp_slb_bandpass_test.m

depends="test/directFIRnonsymmetric_socp_slb_bandpass_test.m test_common.m \
directFIRnonsymmetric_socp_mmse.m directFIRnonsymmetricEsq.m \
directFIRnonsymmetricAsq.m directFIRnonsymmetricP.m directFIRnonsymmetricT.m \
directFIRsymmetricA.m directFIRnonsymmetric_slb.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_update_constraints.m \
hofstetterFIRsymmetric.m lagrange_interp.m xfr2tf.m \
local_max.m print_polynomial.m qroots.oct \
"

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
h = [  -0.0028412292,   0.0007933524,  -0.0086731886,  -0.0115968560, ... 
        0.0016266270,  -0.0050333290,  -0.0084283751,   0.0409100440, ... 
        0.0444217790,  -0.0043218980,   0.0551205885,   0.0502557547, ... 
       -0.2319877784,  -0.3105323458,   0.1332368955,   0.4024877611, ... 
        0.0935153019,  -0.1576707153,  -0.0525956365,  -0.0063873908, ... 
       -0.0717178623,  -0.0201545784,   0.0380182685,   0.0065243013, ... 
        0.0044300695,   0.0251680713,   0.0045923431,  -0.0080194657, ... 
        0.0015323799,  -0.0022071393,  -0.0050466506 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h.ok directFIRnonsymmetric_socp_slb_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h.ok"; fail; fi

#
# this much worked
#
pass

