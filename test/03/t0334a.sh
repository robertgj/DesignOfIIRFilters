#!/bin/sh

prog=sdp_relaxation_directFIRhilbert_12_nbits_test.m
depends="test/sdp_relaxation_directFIRhilbert_12_nbits_test.m \
test_common.m \
sdp_relaxation_directFIRhilbert_mmsePW.m \
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
cat > test_sd_Ito.ok << 'EOF'
hM1_sd_Ito = [       -1,       -1,       -1,       -2, ... 
                     -2,       -2,       -2,       -4, ... 
                     -4,       -4,       -4,       -8, ... 
                     -8,       -8,       -8,      -10, ... 
                    -12,      -12,      -16,      -16, ... 
                    -18,      -20,      -24,      -24, ... 
                    -28,      -32,      -36,      -40, ... 
                    -48,      -52,      -60,      -69, ... 
                    -80,      -96,     -112,     -140, ... 
                   -183,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_Ito.ok"; fail; fi

cat > test_sd_sdp.ok << 'EOF'
hM1_sd_sdp = [       -1,       -1,       -1,       -1, ... 
                     -2,       -2,       -2,       -2, ... 
                     -4,       -4,       -4,       -4, ... 
                     -8,       -8,       -8,      -10, ... 
                    -12,      -12,      -16,      -16, ... 
                    -18,      -20,      -24,      -24, ... 
                    -28,      -32,      -36,      -40, ... 
                    -48,      -52,      -60,      -69, ... 
                    -80,      -96,     -112,     -140, ... 
                   -183,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_sdp.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact &  5.232e-07 &     0.0675 & & \\
12-bit 2-signed-digit &  0.0002086 &     0.4029 & 71 & 31 \\
12-bit 2-signed-digit(Ito) &   7.87e-06 &     0.1384 & 70 & 30 \\
12-bit 2-signed-digit(SDP) &  6.988e-06 &     0.1013 & 70 & 30 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_directFIRhilbert_12_nbits_test"

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

