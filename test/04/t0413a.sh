#!/bin/sh

prog=sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test.m
depends="test/sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test.m \
../directFIRhilbert_bandpass_slb_test_hM2_coef.m \
test_common.m \
directFIRhilbert_sdp_mmsePW.m \
directFIRhilbert_socp_mmsePW.m \
directFIRhilbert_allocsd_Ito.m \
directFIRhilbert_slb.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbertEsqPW.m \
directFIRhilbertA.m \
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
cat > test_hM1_Ito.ok << 'EOF'
hM1_Ito = [      -20,        8,       64,      -30, ... 
                -128,      128,      327,     -868 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_Ito.ok"; fail; fi

cat > test_hM1_sdp.ok << 'EOF'
hM1_sdp = [      -20,        4,       64,      -30, ... 
                -128,       64,      326,     -868 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sdp.ok"; fail; fi

cat > test_hM1_min.ok << 'EOF'
hM1_min = [      -24,        8,       64,      -34, ... 
                -128,      128,      332,     -876 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial &  4.006e-04 &    0.03324 & & \\
12-bit 2-signed-digit &  2.159e-03 &    0.02341 & 16 & 8 \\
12-bit 2-signed-digit &  2.159e-03 &    0.02341 & 16 & 8 \\
12-bit 2-signed-digit(Ito) &  5.067e-04 &    0.01855 & 16 & 8 \\
12-bit 2-signed-digit(SDP) &  7.150e-03 &    0.07213 & 16 & 8 \\
12-bit 2-signed-digit(min) &  3.618e-04 &    0.01413 & 16 & 8 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test"

diff -Bb test_hM1_Ito.ok $nstr"_hM1_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_Ito.ok"; fail; fi

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

