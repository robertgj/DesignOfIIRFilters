#!/bin/sh

prog=sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test.m
depends="test/sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test.m \
test_common.m \
sdp_relaxation_directFIRsymmetric_mmsePW.m \
directFIRsymmetric_socp_mmsePW.m \
directFIRsymmetric_allocsd_Lim.m \
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
cat > test_sd_Lim.ok << 'EOF'
hM1_sd_Lim = [        0,       -5,      -10,       -5, ... 
                     11,       20,       10,       -3, ... 
                      5,       19,        0,      -58, ... 
                    -90,      -35,       75,      132 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_Lim.ok"; fail; fi

cat > test_sd_sdp.ok << 'EOF'
hM1_sd_sdp = [        0,       -5,      -10,       -5, ... 
                     11,       20,       10,       -2, ... 
                      5,       20,        0,      -58, ... 
                    -91,      -36,       75,      132 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_sdp.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.001901 & -43.0 & & \\
10-bit 3-signed-digit & 0.005824 & -33.5 & 34 & 20 \\
10-bit 3-signed-digit(Lim) & 0.002063 & -37.8 & 36 & 22 \\
10-bit 3-signed-digit(SDP) & 0.001874 & -40.5 & 33 & 19 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test"

diff -Bb test_sd_Lim.ok $nstr"_hM1_sd_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sd_Lim.ok"; fail; fi

diff -Bb test_sd_sdp.ok $nstr"_hM1_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sd_sdp.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

