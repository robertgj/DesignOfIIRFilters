#!/bin/sh

prog=sdp_relaxation_directFIRhilbert_12_nbits_test.m
depends="sdp_relaxation_directFIRhilbert_12_nbits_test.m \
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
cat > test_sd_Ito.ok << 'EOF'
hM1_sd_Ito = [     1304,      432,      258,      183, ... 
                    140,      112,       96,       80, ... 
                     68,       60,       52,       48, ... 
                     40,       36,       32,       28, ... 
                     24,       24,       20,       20, ... 
                     16,       16,       12,       12, ... 
                     10,        9,        8,        8, ... 
                      6,        4,        4,        4, ... 
                      4,        4,        2,        2, ... 
                      2,        2,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_Ito.ok"; fail; fi

cat > test_sd_sdp.ok << 'EOF'
hM1_sd_sdp = [     1304,      432,      258,      183, ... 
                    140,      112,       96,       80, ... 
                     68,       60,       52,       48, ... 
                     40,       36,       32,       30, ... 
                     24,       24,       20,       18, ... 
                     16,       16,       12,       12, ... 
                     10,        9,        8,        8, ... 
                      6,        4,        4,        4, ... 
                      2,        2,        2,        2, ... 
                      1,        1,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sd_sdp.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact &  4.693e-07 &     0.0675 & & \\
12-bit 2-signed-digit &  0.0002078 &      0.417 & 71 & 31 \\
12-bit 2-signed-digit(Ito) &   7.63e-06 &     0.1519 & 71 & 31 \\
12-bit 2-signed-digit(SDP) &   6.44e-06 &     0.1007 & 71 & 31 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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

