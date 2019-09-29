#!/bin/sh

prog=socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
depends="socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m \
test_common.m \
directFIRsymmetric_mmsePW.m \
directFIRsymmetric_socp_mmsePW.m \
directFIRsymmetric_allocsd_Ito.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
print_polynomial.m \
local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
bin2SD.oct bin2SPT.oct SeDuMi_1_3/"

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
cat > test_hM1_sd_coef.ok << 'EOF'
hM1_sd = [       -1,      -16,      -34,      -15, ... 
                 39,       68,       32,       -8, ... 
                 28,       84,       -1,     -236, ... 
               -364,     -142,      302,      532 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sd_coef.ok"; fail; fi

cat > test_hM_min_coef.ok << 'EOF'
hM_min = [       -1,      -16,      -33,      -15, ... 
                 39,       68,       32,       -8, ... 
                 28,       82,       -2,     -236, ... 
               -366,     -142,      302,      530 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1_sd_coef.ok \
"socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test_hM1_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_sd_coef.ok"; fail; fi

diff -Bb test_hM_min_coef.ok \
"socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test_hM_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_min_coef.ok"; fail; fi

#
# this much worked
#
pass

