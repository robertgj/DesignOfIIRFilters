#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m
depends="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m \
test_common.m \
schurOneMPAlattice_sdp_mmse.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_allocsd_Lim.m \
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
H2Asq.m H2P.m H2T.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m schurOneMscale.m \
schurdecomp.oct schurexpand.oct schurOneMAPlattice2H.oct \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct bin2SD.oct bin2SPT.oct \
SeDuMi_1_3/"

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
cat > test_A1k0_sd_Lim.ok << 'EOF'
A1k0_sd_Lim = [     -865,     1278,      976,    -1090, ... 
                    1408,     -640,     -128,      784, ... 
                    -496,      192 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_Lim.ok"; fail; fi

cat > test_A2k0_sd_Lim.ok << 'EOF'
A2k0_sd_Lim = [    -1557,     1500,      946,    -1176, ... 
                    1464,     -522,     -120,      768, ... 
                    -488,      192 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_Lim.ok"; fail; fi

cat > test_A1k0_sd_sdp.ok << 'EOF'
A1k0_sd_sdp = [     -864,     1278,      984,    -1090, ... 
                    1408,     -576,     -128,      784, ... 
                    -480,      192 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_sdp.ok"; fail; fi

cat > test_A2k0_sd_sdp.ok << 'EOF'
A2k0_sd_sdp = [    -1557,     1496,      945,    -1176, ... 
                    1464,     -521,     -120,      768, ... 
                    -484,      224 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_sdp.ok"; fail; fi

cat > test_A1k0_sd_min.ok << 'EOF'
A1k0_sd_min = [     -899,     1264,      976,    -1084, ... 
                    1408,     -576,     -128,      776, ... 
                    -480,      224 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_min.ok"; fail; fi

cat > test_A2k0_sd_min.ok << 'EOF'
A2k0_sd_min = [    -1554,     1502,      948,    -1149, ... 
                    1456,     -494,      -96,      768, ... 
                    -464,      224 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.003784 & -35.2 & & \\
12-bit 3-signed-digit & 0.281738 & -29.0 & 60 & 40 \\
12-bit 3-signed-digit(Lim) & 0.240011 & -34.3 & 59 & 39 \\
12-bit 3-signed-digit(SDP) & 0.792950 & -28.2 & 58 & 38 \\
12-bit 3-signed-digit(min) & 0.005787 & -33.4 & 58 & 38 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test"

diff -Bb test_A1k0_sd_Lim.ok $nstr"_A1k0_sd_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sd_Lim.ok"; fail; fi

diff -Bb test_A2k0_sd_Lim.ok $nstr"_A2k0_sd_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd_Lim.ok"; fail; fi

diff -Bb test_A1k0_sd_sdp.ok $nstr"_A1k0_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sd_sdp.ok"; fail; fi

diff -Bb test_A2k0_sd_sdp.ok $nstr"_A2k0_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd_sdp.ok"; fail; fi

diff -Bb test_A1k0_sd_min.ok $nstr"_A1k0_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sd_min.ok"; fail; fi

diff -Bb test_A2k0_sd_min.ok $nstr"_A2k0_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

