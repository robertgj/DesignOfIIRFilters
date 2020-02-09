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
hM_Lim_12_bits = [       -1,       -1,       -1,       -2, ... 
                         -2,       -2,        0,       -4, ... 
                         -4,       -4,       -5,       -6, ... 
                         -6,       -7,       -9,      -10, ... 
                        -12,      -12,      -14,      -16, ... 
                        -18,      -16,      -16,      -32, ... 
                        -28,      -33,      -36,      -40, ... 
                        -47,      -52,      -60,      -69, ... 
                        -80,      -94,     -113,     -140, ... 
                       -184,     -258,     -432,    -1296 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Lim.ok"; fail; fi

cat > test_2_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [       -1,       -1,       -1,       -2, ... 
                         -2,       -2,       -4,       -3, ... 
                         -4,       -4,       -4,       -8, ... 
                         -8,       -8,       -8,       -8, ... 
                        -12,      -12,      -16,      -16, ... 
                        -18,      -20,      -24,      -24, ... 
                        -28,      -32,      -36,      -40, ... 
                        -48,      -52,      -60,      -68, ... 
                        -80,      -96,     -112,     -140, ... 
                       -184,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Ito.ok"; fail; fi

cat > test_3_12_hM_Lim.ok << 'EOF'
hM_Lim_12_bits = [       -1,       -1,       -1,       -2, ... 
                         -2,       -2,       -4,       -3, ... 
                         -4,       -4,       -5,       -6, ... 
                         -6,       -7,       -9,      -10, ... 
                        -11,      -13,      -14,      -16, ... 
                        -18,      -20,      -24,      -24, ... 
                        -29,      -33,      -37,      -41, ... 
                        -47,      -53,      -60,      -69, ... 
                        -80,      -94,     -113,     -141, ... 
                       -183,     -258,     -433,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_hM_Lim.ok"; fail; fi

cat > test_3_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [       -1,       -1,       -1,       -2, ... 
                         -2,       -2,       -4,       -3, ... 
                         -4,       -4,       -5,       -8, ... 
                         -8,       -8,       -8,      -10, ... 
                        -12,      -13,      -16,      -16, ... 
                        -18,      -20,      -24,      -26, ... 
                        -29,      -32,      -36,      -40, ... 
                        -48,      -52,      -60,      -68, ... 
                        -80,      -96,     -112,     -140, ... 
                       -183,     -258,     -432,    -1304 ]'/2048;
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

