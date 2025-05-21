#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m
depends=\
"test/sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m \
test_common.m \
schurOneMPAlattice_sdp_mmse.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_allocsd_Ito.m \
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
schurOneMPAlatticedAsqdw.m \
H2Asq.m H2P.m H2T.m H2dAsqdw.m print_polynomial.m local_max.m flt2SD.m \
SDadders.m x2nextra.m bin2SDul.m tf2pa.m schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m schurOneMscale.m qroots.oct \
spectralfactor.oct bin2SD.oct bin2SPT.oct schurdecomp.oct \
schurexpand.oct schurOneMAPlattice2H.oct schurOneMlattice2Abcd.oct \
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
cat > test_A1k0_sd.ok << 'EOF'
A1k0_sd = [   -19680,    32377,   -25792,    28320, ... 
              -23524,    11812 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd.ok"; fail; fi

cat > test_A2k0_sd.ok << 'EOF'
A2k0_sd = [   -22590,    30739,   -26768,    23872, ... 
              -11752 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd.ok"; fail; fi

cat > test_A1k0_sdp.ok << 'EOF'
A1k0_sdp = [   -19680,    32377,   -25792,    28304, ... 
               -23524,    11812 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sdp.ok"; fail; fi

cat > test_A2k0_sdp.ok << 'EOF'
A2k0_sdp = [   -22590,    30739,   -26784,    23872, ... 
               -11752 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sdp.ok"; fail; fi

cat > test_A1k_min.ok << 'EOF'
A1k_min = [   -19680,    32376,   -25792,    28304, ... 
              -23520,    11810 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min.ok"; fail; fi

cat > test_A2k_min.ok << 'EOF'
A2k_min = [   -22591,    30741,   -26768,    23872, ... 
              -11752 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial & 7.52e-06 & -84.0 & & \\
16-bit 5-signed-digit & 2.43e-05 & -51.7 & 55 & 44 \\
16-bit 5-signed-digit(SDP) & 7.91e-06 & -59.4 & 55 & 44 \\
16-bit 5-signed-digit(min) & 7.53e-06 & -78.0 & 53 & 42 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test"

diff -Bb test_A1k0_sd.ok $nstr"_A1k0_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sd.ok"; fail; fi

diff -Bb test_A2k0_sd.ok $nstr"_A2k0_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd.ok"; fail; fi

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

