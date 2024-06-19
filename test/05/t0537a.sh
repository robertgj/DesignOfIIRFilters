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
local_max.m print_polynomial.m qroots.m \
qzsolve.oct"

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
h = [  -0.0028467207,   0.0006476462,  -0.0086666490,  -0.0117339352, ... 
        0.0013358934,  -0.0049350057,  -0.0085071742,   0.0408410673, ... 
        0.0447144697,  -0.0039663030,   0.0550589972,   0.0505163440, ... 
       -0.2318274887,  -0.3108724588,   0.1330876947,   0.4024620875, ... 
        0.0930131661,  -0.1578775283,  -0.0523194757,  -0.0062755881, ... 
       -0.0716293192,  -0.0197389282,   0.0382082391,   0.0064384378, ... 
        0.0044589137,   0.0250700759,   0.0044139708,  -0.0082307305, ... 
        0.0015695252,  -0.0023735018,  -0.0050359143 ]';
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

