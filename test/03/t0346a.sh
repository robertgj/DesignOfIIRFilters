#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m
depends="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m \
test_common.m \
tf2schurOneMlattice.m \
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
H2Asq.m H2P.m H2T.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
schurOneMAPlattice2Abcd.m schurOneMscale.m \
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
cat > test_A1k0_sd_Ito.ok << 'EOF'
A1k0_sd_Ito = [     -839,     1800,    -1158,     1640, ... 
                    -928,      960,     -320,      160, ... 
                      32,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_Ito.ok"; fail; fi

cat > test_A2k0_sd_Ito.ok << 'EOF'
A2k0_sd_Ito = [    -1568,     1824,    -1188,     1616, ... 
                    -880,      992,     -320,      176, ... 
                      48,        4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_Ito.ok"; fail; fi

cat > test_A1k0_sd_sdp.ok << 'EOF'
A1k0_sd_sdp = [     -838,     1800,    -1157,     1636, ... 
                    -928,      960,     -288,      160, ... 
                      16,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_sdp.ok"; fail; fi

cat > test_A2k0_sd_sdp.ok << 'EOF'
A2k0_sd_sdp = [    -1568,     1808,    -1188,     1616, ... 
                    -880,      992,     -320,      184, ... 
                      48,        4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_sdp.ok"; fail; fi

cat > test_A1k0_sd_min.ok << 'EOF'
A1k0_sd_min = [     -836,     1772,    -1136,     1644, ... 
                    -928,      960,     -288,      192, ... 
                      32,        8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_min.ok"; fail; fi

cat > test_A2k0_sd_min.ok << 'EOF'
A2k0_sd_min = [    -1568,     1824,    -1188,     1616, ... 
                    -864,      992,     -320,      208, ... 
                      48,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.000519 & -40.0 & & \\
12-bit 3-signed-digit & 0.082588 & -26.5 & 55 & 35 \\
12-bit 3-signed-digit(Ito) & 0.008675 & -36.4 & 55 & 35 \\
12-bit 3-signed-digit(SDP) & 0.252699 & -29.5 & 55 & 35 \\
12-bit 3-signed-digit(min) & 0.004030 & -30.7 & 54 & 34 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test"

diff -Bb test_A1k0_sd_Ito.ok $nstr"_A1k0_sd_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_sd_Ito.ok"; fail; fi

diff -Bb test_A2k0_sd_Ito.ok $nstr"_A2k0_sd_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd_Ito.ok"; fail; fi

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

