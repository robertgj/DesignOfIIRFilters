#!/bin/sh

prog=schurOneMlattice_bandpass_allocsd_test.m
depends="test/schurOneMlattice_bandpass_allocsd_test.m test_common.m \
../schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m \
schurOneMlattice_bandpass_10_nbits_common.m \
schurOneMlattice_allocsd_Ito.m schurOneMlattice_allocsd_Lim.m bin2SDul.m \
schurOneMlatticeEsq.m H2Asq.m schurOneMlatticeAsq.m schurOneMlatticeT.m \
schurOneMlatticeP.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
schurOneMlatticeNoiseGain.m tf2schurOneMlattice.m schurOneMscale.m \
print_polynomial.m H2T.m H2P.m flt2SD.m x2nextra.m schurOneMR2lattice2Abcd.m \
KW.m SDadders.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bitflip.oct bin2SPT.oct Abcd2tf.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct complex_zhong_inverse.oct"

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
k_Lim_12_bits = [        0,     1360,        0,     1017, ... 
                         0,      708,        0,      896, ... 
                         0,      640,        0,      515, ... 
                         0,      320,        0,      208, ... 
                         0,       72,        0,       32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      144,      -24,     -608,     -992, ... 
                      -320,      251,      800,      608, ... 
                        36,     -168,     -164,      -32, ... 
                       -16,      -72,      -48,        0, ... 
                        64,        0,        0,        0, ... 
                         0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [        0,     1360,        0,     1024, ... 
                         0,      704,        0,      856, ... 
                         0,      608,        0,      512, ... 
                         0,      312,        0,      208, ... 
                         0,       72,        0,       32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      144,      -32,     -608,     -992, ... 
                      -336,      256,      800,      608, ... 
                        32,     -168,     -160,      -32, ... 
                       -16,      -72,      -48,        8, ... 
                        48,       32,        8,        4, ... 
                        16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [        0,     1368,        0,     1017, ... 
                         0,      709,        0,      864, ... 
                         0,      608,        0,      515, ... 
                         0,      312,        0,      209, ... 
                         0,       74,        0,       31 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_c_Lim.ok << 'EOF'
c_Lim_12_bits = [      144,      -26,     -612,     -988, ... 
                      -336,      251,      808,      616, ... 
                        35,     -169,     -163,      -24, ... 
                       -20,      -72,      -52,        8, ... 
                        48,       32,        8,        4, ... 
                        16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [        0,     1360,        0,     1024, ... 
                         0,      708,        0,      856, ... 
                         0,      609,        0,      515, ... 
                         0,      310,        0,      208, ... 
                         0,       74,        0,       32 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_c_Ito.ok << 'EOF'
c_Ito_12_bits = [      144,      -24,     -612,     -988, ... 
                      -336,      252,      808,      616, ... 
                        32,     -168,     -160,      -24, ... 
                       -20,      -72,      -52,        8, ... 
                        50,       32,        8,        4, ... 
                        12 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_bandpass_allocsd_test"

diff -Bb test_2_12_k_Lim.ok $nstr"_2_ndigits_12_nbits_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Lim.ok"; fail; fi

diff -Bb test_2_12_c_Lim.ok $nstr"_2_ndigits_12_nbits_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Lim.ok"; fail; fi

diff -Bb test_2_12_k_Ito.ok $nstr"_2_ndigits_12_nbits_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Ito.ok"; fail; fi

diff -Bb test_2_12_c_Ito.ok $nstr"_2_ndigits_12_nbits_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Ito.ok"; fail; fi

diff -Bb test_3_12_k_Lim.ok $nstr"_3_ndigits_12_nbits_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Lim.ok"; fail; fi

diff -Bb test_3_12_c_Lim.ok $nstr"_3_ndigits_12_nbits_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Lim.ok"; fail; fi

diff -Bb test_3_12_k_Ito.ok $nstr"_3_ndigits_12_nbits_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Ito.ok"; fail; fi

diff -Bb test_3_12_c_Ito.ok $nstr"_3_ndigits_12_nbits_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Ito.ok"; fail; fi

#
# this much worked
#
pass

