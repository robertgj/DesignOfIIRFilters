#!/bin/sh

prog=sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
depends="test/sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m \
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
hM1_sd = [        1,      -20,      -48,      -20, ... 
                 48,       96,       48,      -12, ... 
                 12,       80,        1,     -248, ... 
               -384,     -160,      320,      576 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sd.ok"; fail; fi

cat > test_hM1_sdp.ok << 'EOF'
hM1_sdp = [        0,      -24,      -48,      -20, ... 
                  48,       96,       48,      -14, ... 
                  14,       80,        1,     -248, ... 
                -384,     -160,      320,      576 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sdp.ok"; fail; fi

cat > test_hM1_min.ok << 'EOF'
hM1_min = [       -1,      -24,      -48,      -24, ... 
                  48,       96,       48,      -15, ... 
                   9,       80,        7,     -240, ... 
                -384,     -160,      320,      576 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial &  1.389e-03 &    0.07924 & & \\
12-bit 2-signed-digit &  3.261e-03 &    0.08112 & 30 & 14 \\
12-bit 2-signed-digit(SDP) &  3.008e-03 &    0.08585 & 29 & 14 \\
12-bit 2-signed-digit(min) &  2.050e-03 &    0.09326 & 31 & 15 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test"

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

