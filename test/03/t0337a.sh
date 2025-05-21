#!/bin/sh

prog=sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test.m
depends="test/sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test.m \
test_common.m \
directFIRsymmetric_sdp_mmsePW.m \
directFIRsymmetric_socp_mmsePW.m \
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
bin2SD.oct bin2SPT.oct"

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
cat > test_hM1_sd.ok << 'EOF'
hM1_sd = [        0,       -5,      -12,       -5, ... 
                 12,       24,       12,       -3, ... 
                  3,       20,        0,      -60, ... 
                -96,      -40,       80,      144 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sd.ok"; fail; fi

cat > test_hM1_sdp.ok << 'EOF'
hM1_sdp = [        0,       -6,      -12,       -5, ... 
                  12,       24,       12,       -4, ... 
                   3,       20,        0,      -62, ... 
                 -96,      -40,       80,      144 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sdp.ok"; fail; fi

cat > test_hM1_min.ok << 'EOF'
hM1_min = [        0,       -6,      -12,       -6, ... 
                  12,       24,       12,       -4, ... 
                   2,       20,        2,      -60, ... 
                 -96,      -40,       80,      144 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial &  1.389e-03 &    0.07924 & & \\
10-bit 2-signed-digit &  3.146e-03 &    0.08532 & 28 & 14 \\
10-bit 2-signed-digit(SDP) &  3.149e-03 &    0.08725 & 27 & 13 \\
10-bit 2-signed-digit(min) &  2.032e-03 &    0.09449 & 27 & 12 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test"

diff -Bb test_hM1_sd.ok $nstr"_hM1_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_sd.ok"; fail; fi

diff -Bb test_hM1_sdp.ok $nstr"_hM1_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_sdp.ok"; fail; fi

diff -Bb test_hM1_min.ok $nstr"_hM1_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

