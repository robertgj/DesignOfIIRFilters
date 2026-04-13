#!/bin/sh

prog=schurOneMlatticePipelined_bandpass_allocsd_test.m
depends="test/schurOneMlatticePipelined_bandpass_allocsd_test.m test_common.m \
../schurOneMlattice_socp_slb_bandpass_test_N3_coef.m \
../schurOneMlattice_socp_slb_bandpass_test_D3_coef.m \
schurOneMlattice_bandpass_10_nbits_common.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlatticeEsq.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticePipelined_allocsd_Ito.m \
schurOneMlatticePipelined_allocsd_Lim.m \
schurOneMlatticePipelinedEsq.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedP.m
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelineddAsqdw.m \
tf2schurOneMlatticePipelined.m \
schurOneMlatticePipelined2Abcd.m \
schurOneMlattice2tf.m \
tf2schurOneMlattice.m \
schurOneMscale.m KW.m SDadders.m qroots.oct \
print_polynomial.m H2T.m H2P.m H2Asq.m flt2SD.m x2nextra.m bin2SDul.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct Abcd2tf.oct \
Abcd2H.oct schurOneMlattice2Abcd.oct schurOneMlattice2H.oct \
complex_zhong_inverse.oct"

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
cat > test_2_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [    -1880,     1964,    -1520,     1280, ... 
                     -1508,     1024,    -1508,     1344, ... 
                     -1182,      624,     -268,        0, ... 
                       -96,      -40,        0,      -40, ... 
                       -56,        0,       -8,      -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      384,     -128,    -1152,     -704, ... 
                       224,     1616,      112,     -832, ... 
                      -192,        0,       32,      -48, ... 
                       -32,       32,       64,        0, ... 
                         0,        0,       16,        0, ... 
                       -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi

cat > test_2_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1804,    -1456,     -991,     -984, ... 
                      -1105,    -1104,     -987,     -776, ... 
                       -352,      -80,        0,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Lim.ok"; fail; fi

cat > test_2_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -148,        0,     -464,        0, ... 
                       1184,        0,     -552,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1920,     1968,    -1520,     1336, ... 
                     -1504,     1504,    -1508,     1344, ... 
                     -1184,      624,     -264,       -4, ... 
                       -96,      -40,       -2,      -40, ... 
                       -56,       -1,       -8,      -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      512,     -128,    -1152,     -704, ... 
                       224,     1616,      128,     -848, ... 
                      -208,       16,       32,      -32, ... 
                       -32,       32,       64,       16, ... 
                        -8,        8,       16,        4, ... 
                       -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi

cat > test_2_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1792,    -1456,     -992,     -984, ... 
                      -1104,    -1104,     -992,     -768, ... 
                       -352,      -80,        1,        0, ... 
                          2,        0,        0,        1, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Ito.ok"; fail; fi

cat > test_2_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -144,        0,     -480,        0, ... 
                       1184,        0,     -552,        0, ... 
                          4,        0,        0,        0, ... 
                         -1,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [    -1881,     1965,    -1520,     1344, ... 
                     -1509,     1504,    -1507,     1340, ... 
                     -1182,      616,     -267,       -4, ... 
                      -104,      -44,       -2,      -42, ... 
                       -52,       -1,       -7,      -15 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      392,     -160,    -1136,     -716, ... 
                       223,     1617,      114,     -848, ... 
                      -208,       16,       28,      -44, ... 
                       -24,       48,       59,       16, ... 
                         0,        8,       16,        0, ... 
                       -18 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi

cat > test_3_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1805,    -1458,     -991,     -984, ... 
                      -1105,    -1103,     -987,     -774, ... 
                       -356,      -80,        0,        0, ... 
                          2,        0,        0,        1, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Lim.ok"; fail; fi

cat > test_3_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -147,        0,     -468,        0, ... 
                       1183,        0,     -553,        0, ... 
                          4,        0,        0,        0, ... 
                         -1,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_ck_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1888,     1968,    -1520,     1336, ... 
                     -1509,     1500,    -1508,     1340, ... 
                     -1182,      616,     -268,       -4, ... 
                      -104,      -43,       -2,      -40, ... 
                       -52,       -1,       -8,      -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      384,     -128,    -1136,     -720, ... 
                       223,     1617,      112,     -844, ... 
                      -208,       16,       28,      -48, ... 
                       -24,       48,       64,       16, ... 
                        -8,        8,       16,        4, ... 
                       -18 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

cat > test_3_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1792,    -1458,     -992,     -984, ... 
                      -1104,    -1104,     -988,     -776, ... 
                       -352,      -80,        1,        0, ... 
                          2,        0,        0,        1, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Ito.ok"; fail; fi

cat > test_3_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -144,        0,     -464,        0, ... 
                       1183,        0,     -552,        0, ... 
                          4,        0,        0,        0, ... 
                         -1,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_ck_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlatticePipelined_bandpass_allocsd_test"

diff -Bb test_2_12_k_Lim.ok $nstr"_2_ndigits_12_nbits_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Lim.ok"; fail; fi

diff -Bb test_2_12_c_Lim.ok $nstr"_2_ndigits_12_nbits_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Lim.ok"; fail; fi

diff -Bb test_2_12_kk_Lim.ok $nstr"_2_ndigits_12_nbits_kk_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_kk_Lim.ok"; fail; fi

diff -Bb test_2_12_ck_Lim.ok $nstr"_2_ndigits_12_nbits_ck_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_ck_Lim.ok"; fail; fi

diff -Bb test_2_12_k_Ito.ok $nstr"_2_ndigits_12_nbits_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Ito.ok"; fail; fi

diff -Bb test_2_12_c_Ito.ok $nstr"_2_ndigits_12_nbits_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Ito.ok"; fail; fi

diff -Bb test_2_12_kk_Ito.ok $nstr"_2_ndigits_12_nbits_kk_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_kk_Ito.ok"; fail; fi

diff -Bb test_2_12_ck_Ito.ok $nstr"_2_ndigits_12_nbits_ck_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_ck_Ito.ok"; fail; fi

diff -Bb test_3_12_k_Lim.ok $nstr"_3_ndigits_12_nbits_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Lim.ok"; fail; fi

diff -Bb test_3_12_c_Lim.ok $nstr"_3_ndigits_12_nbits_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Lim.ok"; fail; fi

diff -Bb test_3_12_kk_Lim.ok $nstr"_3_ndigits_12_nbits_kk_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_kk_Lim.ok"; fail; fi

diff -Bb test_3_12_ck_Lim.ok $nstr"_3_ndigits_12_nbits_ck_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_ck_Lim.ok"; fail; fi

diff -Bb test_3_12_k_Ito.ok $nstr"_3_ndigits_12_nbits_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Ito.ok"; fail; fi

diff -Bb test_3_12_c_Ito.ok $nstr"_3_ndigits_12_nbits_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Ito.ok"; fail; fi

diff -Bb test_3_12_kk_Ito.ok $nstr"_3_ndigits_12_nbits_kk_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_kk_Ito.ok"; fail; fi

diff -Bb test_3_12_ck_Ito.ok $nstr"_3_ndigits_12_nbits_ck_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_ck_Ito.ok"; fail; fi

#
# this much worked
#
pass

