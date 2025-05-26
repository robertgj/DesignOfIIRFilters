#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m
depends=\
"test/sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m \
test_common.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2p_coef.m \
schurOneMPAlattice_sdp_mmse.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_allocsd_Ito.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticedAsqdw.m \
H2Asq.m H2P.m H2T.m H2dAsqdw.m delayz.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m schurOneMscale.m \
schurdecomp.oct schurexpand.oct schurOneMAPlattice2H.oct \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct bin2SD.oct bin2SPT.oct"

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
cat > test_A1k0_Ito.ok << 'EOF'
A1k0_Ito = [    -1856,     3392,     -944,      208, ... 
                 2784,    -1344,      416,     2144, ... 
                -1536,     1088 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_Ito.ok"; fail; fi

cat > test_A2k0_Ito.ok << 'EOF'
A2k0_Ito = [    -3312,     3600,    -1216,       64, ... 
                 2848,    -1216,      448,     2144, ... 
                -1488,     1104 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_Ito.ok"; fail; fi

cat > test_A1k0_sdp.ok << 'EOF'
A1k0_sdp = [    -1888,     3392,     -944,      208, ... 
                 2800,    -1344,      432,     2160, ... 
                -1536,     1088 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sdp.ok"; fail; fi

cat > test_A2k0_sdp.ok << 'EOF'
A2k0_sdp = [    -3312,     3592,    -1216,      128, ... 
                 2848,    -1216,      480,     2160, ... 
                -1480,     1104 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sdp.ok"; fail; fi

cat > test_A1k_min.ok << 'EOF'
A1k_min = [    -1856,     3392,     -952,      200, ... 
                2784,    -1344,      416,     2128, ... 
               -1536,     1088 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "failed output cat test_A1k_min.ok"; fail; fi

cat > test_A2k_min.ok << 'EOF'
A2k_min = [    -3312,     3592,    -1248,       64, ... 
                2848,    -1216,      448,     2144, ... 
               -1480,     1120 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.001521 & -39.9 & & \\
13-bit 3-signed-digit & 0.121881 & -16.2 & 60 & 40 \\
13-bit 3-signed-digit(Ito) & 0.004232 & -37.8 & 60 & 40 \\
13-bit 3-signed-digit(SDP) & 0.008065 & -22.5 & 60 & 40 \\
13-bit 3-signed-digit(min) & 0.001264 & -36.1 & 60 & 40 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test"

diff -Bb test_A1k0_Ito.ok $nstr"_A1k0_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_Ito.ok"; fail; fi

diff -Bb test_A2k0_Ito.ok $nstr"_A2k0_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_Ito.ok"; fail; fi

diff -Bb test_A1k0_sdp.ok $nstr"_A1k0_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sdp.ok"; fail; fi

diff -Bb test_A2k0_sdp.ok $nstr"_A2k0_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sdp.ok"; fail; fi

diff -Bb test_A1k_min.ok $nstr"_A1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_min.ok"; fail; fi

diff -Bb test_A2k_min.ok $nstr"_A2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

