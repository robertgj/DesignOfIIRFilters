#!/bin/sh

prog=socp_relaxation_directFIRhilbert_12_nbits_test.m
depends="socp_relaxation_directFIRhilbert_12_nbits_test.m \
test_common.m \
directFIRhilbert_mmsePW.m \
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
cat > test_hM0_Ito_sd_coef.ok << 'EOF'
hM0_Ito_sd = [     1304,      432,      258,      183, ... 
                    140,      112,       96,       80, ... 
                     69,       60,       52,       48, ... 
                     40,       36,       32,       28, ... 
                     24,       24,       20,       20, ... 
                     16,       16,       12,       12, ... 
                     10,        9,        8,        8, ... 
                      6,        4,        4,        4, ... 
                      4,        4,        2,        2, ... 
                      2,        2,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM0_Ito_sd_coef.ok"; fail; fi

cat > test_hM_min_coef.ok << 'EOF'
hM_min = [     1304,      432,      258,      183, ... 
                140,      112,       96,       80, ... 
                 69,       60,       54,       48, ... 
                 40,       36,       32,       30, ... 
                 28,       24,       20,       18, ... 
                 16,       16,       12,       12, ... 
                 10,        9,        8,        8, ... 
                  6,        4,        4,        4, ... 
                  2,        2,        2,        2, ... 
                  1,        1,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM0_Ito_sd_coef.ok \
"socp_relaxation_directFIRhilbert_12_nbits_test_hM0_Ito_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM0_Ito_sd_coef.ok"; fail; fi

diff -Bb test_hM_min_coef.ok \
"socp_relaxation_directFIRhilbert_12_nbits_test_hM_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_min_coef.ok"; fail; fi

#
# this much worked
#
pass

