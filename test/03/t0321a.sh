#!/bin/sh

prog=directFIRsymmetric_socp_mmse_test.m
depends="directFIRsymmetric_socp_mmse_test.m test_common.m \
directFIRsymmetric_socp_mmse.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetricEsq.m \
directFIRsymmetricA.m \
print_polynomial.m \
local_max.m \
SeDuMi_1_3/"

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
hM1 = [  -0.00085887,  -0.01267358,  -0.01943551,  -0.00576857, ... 
          0.02368677,   0.03572970,   0.01411343,  -0.00667201, ... 
          0.01263907,   0.04115553,   0.00068723,  -0.11131368, ... 
         -0.17170917,  -0.06644507,   0.14087704,   0.24750853 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1_coef.ok "directFIRsymmetric_socp_mmse_test_hM1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_coef.ok"; fail; fi

#
# this much worked
#
pass

