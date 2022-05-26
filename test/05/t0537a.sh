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
h = [  -0.0019642625,   0.0007578958,  -0.0075787731,  -0.0106375452, ... 
        0.0020404034,  -0.0050800933,  -0.0081235923,   0.0399859924, ... 
        0.0431671090,  -0.0048672004,   0.0549337448,   0.0496905196, ... 
       -0.2311337481,  -0.3094786638,   0.1335790745,   0.4027702014, ... 
        0.0945777818,  -0.1576495799,  -0.0532050324,  -0.0068589551, ... 
       -0.0719163693,  -0.0210123115,   0.0377263407,   0.0066611764, ... 
        0.0047149564,   0.0252440369,   0.0055235877,  -0.0077889125, ... 
        0.0022898825,  -0.0021626030,  -0.0045963640 ]';
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

