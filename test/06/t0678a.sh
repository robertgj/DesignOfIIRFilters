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
k_Lim_12_bits = [    -1808,     1991,    -1396,     1536, ... 
                     -1216,     1696,    -1352,     1560, ... 
                     -1208,     1064,     -380,       96, ... 
                        48,       40,       -8,       24, ... 
                       -56,       60,      -36,        8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [     -384,     -256,    -1792,    -1282, ... 
                        64,     2038,     3072,    -1280, ... 
                      -384,        0,       32,      -48, ... 
                       -32,       32,       62,        0, ... 
                         0,        0,       16,        0, ... 
                       -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi

cat > test_2_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1756,    -1356,    -1088,     -964, ... 
                      -1000,    -1120,    -1028,     -896, ... 
                       -624,     -192,      -18,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Lim.ok"; fail; fi

cat > test_2_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -249,        0,    -1020,        0, ... 
                       1680,        0,    -1040,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1792,     1984,    -1392,     1632, ... 
                     -1216,     1696,    -1352,     1560, ... 
                     -1208,     1056,     -384,       96, ... 
                        48,       40,       -8,       24, ... 
                       -52,       64,      -36,        8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [     -384,     -256,    -1792,    -1280, ... 
                        80,     2048,     3008,    -1360, ... 
                      -384,      -32,       32,      -48, ... 
                       -32,       32,       64,       32, ... 
                        -4,        8,       16,        8, ... 
                       -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi

cat > test_2_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1760,    -1360,    -1104,     -960, ... 
                       -992,    -1112,    -1028,     -920, ... 
                       -624,     -192,      -16,        2, ... 
                          1,        0,        0,       -1, ... 
                         -2,       -1,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Ito.ok"; fail; fi

cat > test_2_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -256,        0,    -1024,        0, ... 
                       1680,        0,    -1024,        0, ... 
                        -16,        0,       -2,        0, ... 
                          1,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [    -1806,     1991,    -1395,     1600, ... 
                     -1212,     1688,    -1350,     1560, ... 
                     -1207,     1064,     -380,       95, ... 
                        50,       41,       -6,       24, ... 
                       -52,       61,      -37,        8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [     -392,     -256,    -1800,    -1282, ... 
                        80,     2038,     3000,    -1344, ... 
                      -368,      -32,       28,      -48, ... 
                       -36,       40,       62,       32, ... 
                         0,        8,       18,        8, ... 
                       -20 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi

cat > test_3_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1756,    -1356,    -1112,     -965, ... 
                       -999,    -1112,    -1028,     -912, ... 
                       -628,     -196,      -18,        2, ... 
                          1,        0,        0,        0, ... 
                         -2,       -1,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Lim.ok"; fail; fi

cat > test_3_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -249,        0,    -1020,        0, ... 
                       1679,        0,    -1038,        0, ... 
                        -16,        0,       -2,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_ck_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1792,     1984,    -1396,     1632, ... 
                     -1216,     1688,    -1352,     1560, ... 
                     -1208,     1056,     -380,       95, ... 
                        48,       41,       -8,       24, ... 
                       -53,       60,      -37,        8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [     -384,     -256,    -1792,    -1280, ... 
                        80,     2040,     3008,    -1360, ... 
                      -369,      -32,       32,      -48, ... 
                       -36,       40,       64,       24, ... 
                        -4,        8,       18,        8, ... 
                       -20 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

cat > test_3_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1756,    -1360,    -1112,     -960, ... 
                      -1000,    -1113,    -1028,     -920, ... 
                       -628,     -196,      -18,        2, ... 
                          1,        0,        0,       -1, ... 
                         -2,       -1,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Ito.ok"; fail; fi

cat > test_3_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -248,        0,    -1024,        0, ... 
                       1680,        0,    -1040,        0, ... 
                        -16,        0,       -2,        0, ... 
                          1,        0,        0,        0, ... 
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

