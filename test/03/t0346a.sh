#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m
depends="test/sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m \
test_common.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef.m \
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
A1k0_sd_Lim = [    -1730,     2304,     2160,    -2241, ... 
                    2688,     -960,     -448,     1600, ... 
                   -1072,      544 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_Lim.ok"; fail; fi

cat > test_A2k0_sd_Lim.ok << 'EOF'
A2k0_sd_Lim = [    -3101,     2832,     2126,    -2430, ... 
                    2752,        0,     -388,     1600, ... 
                   -1054,      576 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_Lim.ok"; fail; fi

cat > test_A1k0_sd_sdp.ok << 'EOF'
A1k0_sd_sdp = [    -1729,     2560,     2160,    -2241, ... 
                    2624,     -960,     -384,     1664, ... 
                   -1064,      528 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_sdp.ok"; fail; fi

cat > test_A2k0_sd_sdp.ok << 'EOF'
A2k0_sd_sdp = [    -3101,     2832,     2126,    -2430, ... 
                    2784,        0,     -386,     1568, ... 
                   -1052,      576 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_sdp.ok"; fail; fi

cat > test_A1k0_sd_min.ok << 'EOF'
A1k0_sd_min = [    -1929,     2560,     1904,    -2017, ... 
                    2624,     -192,     -544,     1856, ... 
                    -952,      768 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_min.ok"; fail; fi

cat > test_A2k0_sd_min.ok << 'EOF'
A2k0_sd_min = [    -3172,     3152,     1889,    -2156, ... 
                    2720,        0,     -503,     1776, ... 
                    -976,      768 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.001353 & -33.6 & & \\
13-bit 3-signed-digit & 0.011982 & -29.2 & 60 & 40 \\
13-bit 3-signed-digit(Lim) & 3.012237 & -10.2 & 60 & 41 \\
13-bit 3-signed-digit(SDP) & 4.238714 & -12.5 & 60 & 41 \\
13-bit 3-signed-digit(min) & 0.011049 & -35.2 & 59 & 40 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

