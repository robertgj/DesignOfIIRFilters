#!/bin/sh

prog=directFIRhilbert_allocsd_test.m
depends="directFIRhilbert_allocsd_test.m test_common.m \
directFIRhilbert_allocsd_Ito.m directFIRhilbert_allocsd_Lim.m \
directFIRhilbertEsqPW.m directFIRhilbertA.m \
local_max.m print_polynomial.m flt2SD.m x2nextra.m SDadders.m bin2SDul.m \
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
cat > test_2_12_hM_Lim.ok << 'EOF'
hM_Lim_12_bits = [     1296,      432,      258,      184, ... 
                        140,      114,       94,       80, ... 
                         69,       60,       52,       47, ... 
                         40,       36,       33,       28, ... 
                         24,       16,       16,       20, ... 
                         17,       15,       12,       12, ... 
                         10,        9,        8,        7, ... 
                          6,        5,        4,        4, ... 
                          4,        0,        2,        2, ... 
                          2,        2,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Lim.ok"; fail; fi

cat > test_2_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [     1304,      432,      258,      183, ... 
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
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Ito.ok"; fail; fi

cat > test_3_12_hM_Lim.ok << 'EOF'
hM_Lim_12_bits = [     1304,      433,      258,      183, ... 
                        141,      114,       94,       80, ... 
                         69,       60,       53,       47, ... 
                         41,       37,       33,       29, ... 
                         26,       24,       20,       19, ... 
                         17,       15,       13,       12, ... 
                         10,        9,        8,        7, ... 
                          6,        5,        4,        4, ... 
                          3,        4,        2,        2, ... 
                          2,        2,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_hM_Lim.ok"; fail; fi

cat > test_3_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [     1304,      432,      258,      183, ... 
                        140,      112,       96,       80, ... 
                         69,       60,       52,       48, ... 
                         40,       36,       33,       28, ... 
                         24,       24,       21,       20, ... 
                         16,       16,       12,       12, ... 
                         10,        9,        8,        7, ... 
                          6,        4,        4,        4, ... 
                          4,        4,        2,        2, ... 
                          2,        2,        1,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_hM_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="directFIRhilbert_allocsd_2_ndigits_12_nbits_test"
diff -Bb test_2_12_hM_Lim.ok $nstr"_hM_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_hM_Lim.ok"; fail; fi
diff -Bb test_2_12_hM_Ito.ok $nstr"_hM_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_hM_Ito.ok"; fail; fi

nstr="directFIRhilbert_allocsd_3_ndigits_12_nbits_test"
diff -Bb test_3_12_hM_Lim.ok $nstr"_hM_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_hM_Lim.ok"; fail; fi
diff -Bb test_3_12_hM_Ito.ok $nstr"_hM_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_hM_Ito.ok"; fail; fi

#
# this much worked
#
pass

