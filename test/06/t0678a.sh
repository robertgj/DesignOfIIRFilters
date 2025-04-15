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
k_Lim_12_bits = [    -1880,     1956,     -650,     1680, ... 
                     -1468,     1536,    -1280,     1539, ... 
                     -1153,     1143,     -168,     -276, ... 
                       472,      126,     -352,      304, ... 
                         8,     -132,       96,      -34 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [     -256,     -256,     -768,    -2041, ... 
                        96,     3112,      452,     -896, ... 
                     -1920,        0,        0,      -96, ... 
                       -64,        0,       64,        0, ... 
                         0,        0,       32,        0, ... 
                         0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi

cat > test_2_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1796,     -620,     -536,    -1216, ... 
                      -1159,     -976,     -928,     -864, ... 
                       -644,      -96,       16,      -64, ... 
                         28,      -16,      -48,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Lim.ok"; fail; fi

cat > test_2_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -284,        0,    -1792,        0, ... 
                       2464,        0,     -640,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1920,     1952,     -640,     1680, ... 
                     -1468,     1616,    -1232,     1536, ... 
                     -1153,     1144,     -168,     -276, ... 
                       472,      128,     -352,      304, ... 
                         8,     -128,      104,      -32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [     -256,     -256,     -800,    -2048, ... 
                        64,     3112,      448,     -896, ... 
                     -1904,      -64,       16,      -96, ... 
                       -64,       32,       64,       16, ... 
                         0,       16,       32,       -4, ... 
                        -4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi

cat > test_2_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1792,     -624,     -528,    -1216, ... 
                      -1152,     -960,     -928,     -864, ... 
                       -644,      -96,       24,      -64, ... 
                         32,      -16,      -52,        1, ... 
                         -1,       -8,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_kk_Ito.ok"; fail; fi

cat > test_2_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -256,        0,    -1664,        0, ... 
                       2464,        0,     -640,        0, ... 
                        -32,        0,       16,        0, ... 
                          2,        0,        2,        0, ... 
                         -1,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_ck_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [    -1881,     1955,     -650,     1684, ... 
                     -1467,     1600,    -1248,     1539, ... 
                     -1153,     1143,     -172,     -277, ... 
                       468,      126,     -348,      306, ... 
                         8,     -131,      104,      -34 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [     -320,     -288,     -800,    -2041, ... 
                        92,     3112,      452,     -880, ... 
                     -1904,      -64,       16,      -97, ... 
                       -56,       36,       48,       16, ... 
                         0,       12,       28,        0, ... 
                        -4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi

cat > test_3_12_kk_Lim.ok << 'EOF'
kk_Lim_12_bits = [    -1796,     -620,     -534,    -1208, ... 
                      -1159,     -976,     -928,     -868, ... 
                       -644,      -95,       23,      -64, ... 
                         29,      -20,      -52,        0, ... 
                          0,       -6,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Lim.ok"; fail; fi

cat > test_3_12_ck_Lim.ok << 'EOF'
ck_Lim_12_bits = [     -284,        0,    -1664,        0, ... 
                       2460,        0,     -656,        0, ... 
                        -32,        0,       16,        0, ... 
                          0,        0,        2,        0, ... 
                          0,        0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_ck_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [    -1920,     1952,     -648,     1684, ... 
                     -1467,     1616,    -1236,     1536, ... 
                     -1153,     1143,     -172,     -277, ... 
                       469,      128,     -348,      304, ... 
                         8,     -132,      104,      -32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [     -320,     -256,     -816,    -2048, ... 
                        64,     3112,      448,     -880, ... 
                     -1904,      -64,       16,      -96, ... 
                       -64,       32,       48,       16, ... 
                         0,       16,       28,       -4, ... 
                        -4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

cat > test_3_12_kk_Ito.ok << 'EOF'
kk_Ito_12_bits = [    -1792,     -624,     -536,    -1208, ... 
                      -1159,     -976,     -928,     -867, ... 
                       -644,      -96,       24,      -64, ... 
                         29,      -20,      -52,        1, ... 
                         -1,       -8,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_kk_Ito.ok"; fail; fi

cat > test_3_12_ck_Ito.ok << 'EOF'
ck_Ito_12_bits = [     -288,        0,    -1680,        0, ... 
                       2464,        0,     -656,        0, ... 
                        -32,        0,       16,        0, ... 
                          2,        0,        2,        0, ... 
                         -1,        0,        0 ]'/2048;
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

