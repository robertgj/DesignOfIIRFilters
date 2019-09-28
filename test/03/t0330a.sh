#!/bin/sh

prog=socp_relaxation_directFIRhilbert_10_nbits_test.m
depends="socp_relaxation_directFIRhilbert_10_nbits_test.m \
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
echo $here
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
hM0_Ito_sd = [      326,      108,       64,       46, ... 
                     35,       28,       24,       20, ... 
                     16,       15,       13,       12, ... 
                     10,        9,        8,        8, ... 
                      8,        6,        4,        4, ... 
                      4,        4,        4,        3, ... 
                      4,        2,        2,        2, ... 
                      1,        1,        1,        1, ... 
                      1,        1,        1,        0, ... 
                      0,        0,        0,        0 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM0_Ito_sd_coef.ok"; fail; fi

cat > test_hM_min_coef.ok << 'EOF'
hM_min = [      326,      108,       64,       46, ... 
                 35,       28,       24,       20, ... 
                 16,       15,       13,       12, ... 
                 10,        9,        8,        8, ... 
                  8,        6,        4,        4, ... 
                  4,        4,        4,        3, ... 
                  2,        2,        2,        2, ... 
                  1,        1,        1,        1, ... 
                  1,        1,        1,        0, ... 
                  0,        0,        0,        0 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test_out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM0_Ito_sd_coef.ok \
"socp_relaxation_directFIRhilbert_10_nbits_test_hM0_Ito_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM0_Ito_sd_coef.ok"; fail; fi

diff -Bb test_hM_min_coef.ok \
"socp_relaxation_directFIRhilbert_10_nbits_test_hM_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_min_coef.ok"; fail; fi

#
# this much worked
#
pass

