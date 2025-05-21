#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_14_nbits_test.m
depends=\
"test/sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_14_nbits_test.m \
test_common.m \
schurOneMPAlattice_sdp_mmse.m \
schurOneMPAlattice_socp_mmse.m \
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
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
H2Asq.m H2P.m H2T.m H2dAsqdw.m print_polynomial.m local_max.m flt2SD.m \
SDadders.m x2nextra.m bin2SDul.m tf2pa.m schurOneMscale.m qroots.oct \
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
A1k0_sd = [    -4928,     8094,    -6432,     7072, ... 
               -5880,     2952 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd.ok"; fail; fi

cat > test_A2k0_sd.ok << 'EOF'
A2k0_sd = [    -5648,     7685,    -6688,     5984, ... 
               -2936 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd.ok"; fail; fi

cat > test_A1k0_sdp.ok << 'EOF'
A1k0_sdp = [    -4928,     8095,    -6464,     7072, ... 
                -5880,     2952 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sdp.ok"; fail; fi

cat > test_A2k0_sdp.ok << 'EOF'
A2k0_sdp = [    -5648,     7685,    -6720,     5952, ... 
                -2940 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sdp.ok"; fail; fi

cat > test_A1k_min.ok << 'EOF'
A1k_min = [    -4928,     8092,    -6432,     7088, ... 
               -5884,     2960 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min.ok"; fail; fi

cat > test_A2k_min.ok << 'EOF'
A2k_min = [    -5648,     7682,    -6688,     5984, ... 
               -2940 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial & 7.52e-06 & -84.0 & & \\
14-bit 4-signed-digit & 3.89e-03 & -40.4 & 44 & 33 \\
14-bit 4-signed-digit(SDP) & 2.14e-05 & -51.3 & 44 & 33 \\
14-bit 4-signed-digit(min) & 9.55e-06 & -71.3 & 43 & 32 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_14_nbits_test"

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
