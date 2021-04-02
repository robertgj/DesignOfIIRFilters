#!/bin/sh

prog=directFIRsymmetric_socp_slb_bandpass_test.m
depends="directFIRsymmetric_socp_slb_bandpass_test.m test_common.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_socp_mmsePW.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
local_max.m \
print_polynomial.m"

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
cat > test_hM1_coef.ok << 'EOF'
hM1 = [  -0.00502644,  -0.00049450,  -0.00309351,  -0.01131063, ... 
          0.00598537,   0.01605137,  -0.00107514,   0.02730841, ... 
          0.05043304,  -0.01936237,  -0.02837561,   0.01793398, ... 
         -0.14147613,  -0.24494782,   0.12246831,   0.43432293 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1_coef.ok "directFIRsymmetric_socp_slb_bandpass_test_hM1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_coef.ok"; fail; fi

#
# this much worked
#
pass

