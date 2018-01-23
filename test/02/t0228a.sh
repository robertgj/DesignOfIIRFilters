#!/bin/sh

prog=schurOneMlattice_bandpass_allocsd_test.m
depends="schurOneMlattice_bandpass_allocsd_test.m test_common.m \
schurOneMlattice_bandpass_10_nbits_common.m \
schurOneMlattice_allocsd_Ito.m schurOneMlattice_allocsd_Lim.m bin2SDul.m \
schurOneMlatticeEsq.m H2Asq.m schurOneMlatticeAsq.m schurOneMlatticeT.m \
schurOneMlatticeP.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
schurOneMlatticeNoiseGain.m tf2schurOneMlattice.m Abcd2tf.m schurOneMscale.m \
print_polynomial.m H2T.m H2P.m flt2SD.m x2nextra.m schurOneMR2lattice2Abcd.m \
KW.m SDadders.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bitflip.oct bin2SPT.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct complex_zhong_inverse.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
cat > test_2_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [        0,     1344,        0,     1044, ... 
                         0,      736,        0,      896, ... 
                         0,      608,        0,      513, ... 
                         0,      320,        0,      192, ... 
                         0,       64,        0,       32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      144,      -16,     -576,     -996, ... 
                      -384,      208,      784,      632, ... 
                        56,     -161,     -168,      -28, ... 
                       -16,      -68,      -48,        0, ... 
                        64,       32,        0,        0, ... 
                         8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [        0,     1376,        0,     1040, ... 
                         0,      736,        0,      864, ... 
                         0,      608,        0,      512, ... 
                         0,      304,        0,      208, ... 
                         0,       68,        0,       28 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      144,      -16,     -576,     -992, ... 
                      -352,      224,      784,      640, ... 
                        56,     -160,     -168,      -32, ... 
                       -16,      -64,      -48,        8, ... 
                        48,       32,        4,       -1, ... 
                         8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [        0,     1376,        0,     1044, ... 
                         0,      720,        0,      864, ... 
                         0,      616,        0,      513, ... 
                         0,      304,        0,      208, ... 
                         0,       68,        0,       28 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      152,      -12,     -576,     -997, ... 
                      -352,      210,      784,      634, ... 
                        54,     -161,     -168,      -29, ... 
                       -15,      -67,      -52,        8, ... 
                        48,       36,        4,       -1, ... 
                         9 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [        0,     1376,        0,     1040, ... 
                         0,      720,        0,      864, ... 
                         0,      616,        0,      512, ... 
                         0,      304,        0,      204, ... 
                         0,       69,        0,       27 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      152,      -12,     -576,     -992, ... 
                      -360,      208,      784,      640, ... 
                        54,     -160,     -168,      -32, ... 
                       -16,      -64,      -52,        8, ... 
                        48,       35,        5,       -1, ... 
                         8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test_out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_bandpass_allocsd_2_ndigits_12_nbits_test"
diff -Bb test_2_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Lim.ok"; fail; fi

diff -Bb test_2_12_c_Lim.ok $nstr"_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Lim.ok"; fail; fi

diff -Bb test_2_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Ito.ok"; fail; fi

diff -Bb test_2_12_c_Ito.ok $nstr"_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Ito.ok"; fail; fi

nstr="schurOneMlattice_bandpass_allocsd_3_ndigits_12_nbits_test"
diff -Bb test_3_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Lim.ok"; fail; fi

diff -Bb test_3_12_c_Lim.ok $nstr"_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Lim.ok"; fail; fi

diff -Bb test_3_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Ito.ok"; fail; fi

diff -Bb test_3_12_c_Ito.ok $nstr"_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Ito.ok"; fail; fi

#
# this much worked
#
pass

