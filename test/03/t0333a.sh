#!/bin/sh

prog=sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
depends="sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m \
test_common.m \
sdp_relaxation_directFIRsymmetric_mmsePW.m \
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
cat > test_sd_Ito.ok << 'EOF'
hM1_sd_Ito = [       -2,      -24,      -40,      -16, ... 
                     48,       72,       32,      -16, ... 
                     24,       84,        2,     -228, ... 
                   -352,     -136,      288,      508 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_Ito.ok"; fail; fi

cat > test_sd_sdp.ok << 'EOF'
hM1_sd_sdp = [       -2,      -24,      -40,      -16, ... 
                     48,       72,       32,       -8, ... 
                     28,       84,        1,     -228, ... 
                   -352,     -136,      288,      508 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_sdp.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.001997 & -47.0 & & \\
12-bit 2-signed-digit & 0.016256 & -28.2 & 30 & 14 \\
12-bit 2-signed-digit(Ito) & 0.002318 & -38.3 & 30 & 14 \\
12-bit 2-signed-digit(SDP) & 0.002119 & -41.6 & 30 & 14 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test"

diff -Bb test_sd_Ito.ok $nstr"_hM1_sd_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sd_Ito.ok"; fail; fi

diff -Bb test_sd_sdp.ok $nstr"_hM1_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sd_sdp.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

