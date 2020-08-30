#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m
depends="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m \
test_common.m \
sdp_relaxation_schurOneMPAlattice_mmse.m \
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
cat > test_A1k0_sd_Lim.ok << 'EOF'
A1k0_sd_Lim = [    -1732,     2564,     1936,    -2177, ... 
                    2816,    -1280,     -256,     1568, ... 
                    -992,      384 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_Lim.ok"; fail; fi

cat > test_A2k0_sd_Lim.ok << 'EOF'
A2k0_sd_Lim = [    -3116,     3004,     1880,    -2352, ... 
                    2928,    -1048,     -240,     1536, ... 
                    -976,      384 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_Lim.ok"; fail; fi

cat > test_A1k0_sd_sdp.ok << 'EOF'
A1k0_sd_sdp = [    -1732,     2564,     1952,    -2177, ... 
                    2816,    -1152,     -256,     1568, ... 
                    -960,      384 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_sdp.ok"; fail; fi

cat > test_A2k0_sd_sdp.ok << 'EOF'
A2k0_sd_sdp = [    -3114,     3004,     1880,    -2344, ... 
                    2928,    -1044,     -240,     1536, ... 
                    -968,      448 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_sdp.ok"; fail; fi

cat > test_A1k0_sd_min.ok << 'EOF'
A1k0_sd_min = [    -1793,     2528,     1952,    -2172, ... 
                    2816,    -1152,     -256,     1568, ... 
                    -960,      448 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_min.ok"; fail; fi

cat > test_A2k0_sd_min.ok << 'EOF'
A2k0_sd_min = [    -3110,     3016,     1880,    -2301, ... 
                    2912,     -993,     -192,     1536, ... 
                    -928,      448 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.001399 & -35.2 & & \\
13-bit 3-signed-digit & 0.246859 & -30.8 & 60 & 40 \\
13-bit 3-signed-digit(Lim) & 0.087099 & -34.5 & 59 & 39 \\
13-bit 3-signed-digit(SDP) & 0.413571 & -28.2 & 59 & 39 \\
13-bit 3-signed-digit(min) & 0.001315 & -35.0 & 58 & 38 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test"

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

