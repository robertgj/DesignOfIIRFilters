#!/bin/sh

prog=sdp_relaxation_schurOneMlattice_bandpass_R2_12_nbits_test.m
depends="test/sdp_relaxation_schurOneMlattice_bandpass_R2_12_nbits_test.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_k2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_epsilon2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_p2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_c2_coef.m \
test_common.m \
schurOneMlattice_sdp_mmse.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlatticeEsq.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
H2Asq.m H2P.m H2T.m H2dAsqdw.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
bin2SD.oct bin2SPT.oct Abcd2tf.oct"

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
cat > test_k0_Lim.ok << 'EOF'
k0_Lim = [        0,     1368,        0,     1017, ... 
                  0,      709,        0,      855, ... 
                  0,      609,        0,      515, ... 
                  0,      310,        0,      209, ... 
                  0,       74,        0,       31 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_Lim.ok"; fail; fi

cat > test_c0_Lim.ok << 'EOF'
c0_Lim = [      144,      -26,     -613,     -988, ... 
               -332,      251,      812,      615, ... 
                 35,     -169,     -163,      -26, ... 
                -20,      -72,      -52,       10, ... 
                 50,       34,        6,        3, ... 
                 12 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_Lim.ok"; fail; fi

cat > test_k0_sdp.ok << 'EOF'
k0_sdp = [        0,     1364,        0,     1017, ... 
                  0,      710,        0,      854, ... 
                  0,      609,        0,      514, ... 
                  0,      310,        0,      210, ... 
                  0,       74,        0,       30 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sdp.ok"; fail; fi

cat > test_c0_sdp.ok << 'EOF'
c0_sdp = [      145,      -26,     -613,     -988, ... 
               -334,      251,      812,      616, ... 
                 36,     -169,     -163,      -26, ... 
                -20,      -72,      -52,        9, ... 
                 50,       33,        6,        2, ... 
                 10 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sdp.ok"; fail; fi

cat > test_k_min.ok << 'EOF'
k_min = [        0,     1364,        0,     1033, ... 
                 0,      715,        0,      859, ... 
                 0,      608,        0,      510, ... 
                 0,      306,        0,      208, ... 
                 0,       71,        0,       30 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_min.ok"; fail; fi

cat > test_c_min.ok << 'EOF'
c_min = [      145,      -29,     -613,     -982, ... 
              -328,      245,      796,      606, ... 
                35,     -169,     -167,      -28, ... 
               -17,      -66,      -49,       10, ... 
                50,       35,        5,       -1, ... 
                 7 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.014429 & -36.0 & & \\
12-bit 4-signed-digit & 0.015358 & -35.4 & 96 & 65 \\
12-bit 4-signed-digit(Lim) & 0.014822 & -35.8 & 102 & 71 \\
12-bit 4-signed-digit(SDP) & 0.012654 & -36.0 & 99 & 68 \\
12-bit 4-signed-digit(min) & 0.012843 & -36.0 & 99 & 68 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMlattice_bandpass_R2_12_nbits_test"

diff -Bb test_k0_Lim.ok $nstr"_k0_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_Lim.ok"; fail; fi

diff -Bb test_c0_Lim.ok $nstr"_c0_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0_Lim.ok"; fail; fi

diff -Bb test_k0_sdp.ok $nstr"_k0_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_sdp.ok"; fail; fi

diff -Bb test_c0_sdp.ok $nstr"_c0_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0_sdp.ok"; fail; fi

diff -Bb test_k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_min.ok"; fail; fi

diff -Bb test_c_min.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

