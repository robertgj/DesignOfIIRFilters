#!/bin/sh

prog=sdp_relaxation_directFIRhilbert_12_nbits_test.m
depends="test/sdp_relaxation_directFIRhilbert_12_nbits_test.m \
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
hM1_Ito = [       -2,       -2,       -2,       -2, ... 
                  -2,       -4,       -4,       -4, ... 
                  -4,       -4,       -8,       -8, ... 
                  -8,       -8,      -10,      -12, ... 
                 -12,      -16,      -16,      -16, ... 
                 -20,      -24,      -24,      -28, ... 
                 -32,      -32,      -40,      -42, ... 
                 -48,      -54,      -60,      -72, ... 
                 -80,      -96,     -112,     -141, ... 
                -184,     -260,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_Ito.ok"; fail; fi

cat > test_hM1_sdp.ok << 'EOF'
hM1_sdp = [       -2,       -1,       -2,       -2, ... 
                  -2,       -4,       -4,       -4, ... 
                  -4,       -4,       -8,       -8, ... 
                  -8,       -8,      -10,      -12, ... 
                 -14,      -16,      -16,      -16, ... 
                 -20,      -24,      -24,      -28, ... 
                 -32,      -32,      -40,      -42, ... 
                 -48,      -54,      -62,      -72, ... 
                 -80,      -96,     -112,     -141, ... 
                -184,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_sdp.ok"; fail; fi

cat > test_hM1_min.ok << 'EOF'
hM1_min = [       -1,       -1,       -1,       -2, ... 
                  -2,       -2,       -4,       -4, ... 
                  -4,       -4,       -4,       -8, ... 
                  -8,       -8,      -10,      -10, ... 
                 -12,      -16,      -15,      -16, ... 
                 -20,      -20,      -24,      -28, ... 
                 -32,      -32,      -36,      -42, ... 
                 -48,      -54,      -60,      -68, ... 
                 -80,      -96,     -112,     -141, ... 
                -184,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_min.ok"; fail; fi

cat > test_hM1_cost.ok << 'EOF'
Initial &  8.101e-07 &    0.01078 & & \\
Exact(SOCP) &  8.101e-07 &    0.00231 & & \\
12-bit 2-signed-digit &  2.078e-04 &    0.04514 & 72 & 32 \\
12-bit 2-signed-digit(Ito) &  1.192e-05 &    0.01241 & 69 & 29 \\
12-bit 2-signed-digit(SDP) &  1.147e-05 &    0.01421 & 69 & 29 \\
12-bit 2-signed-digit(min) &  9.737e-06 &    0.01205 & 70 & 30 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRhilbert_12_nbits_test"

diff -Bb test_hM1_Ito.ok $nstr"_hM1_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_Ito.ok"; fail; fi

diff -Bb test_hM1_sdp.ok $nstr"_hM1_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_sdp.ok"; fail; fi

diff -Bb test_hM1_min.ok $nstr"_hM1_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_min.ok"; fail; fi

diff -Bb test_hM1_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_cost.ok"; fail; fi

#
# this much worked
#
pass

