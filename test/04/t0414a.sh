#!/bin/sh

prog=sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m
depends="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m \
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
H2Asq.m H2P.m H2T.m print_polynomial.m local_max.m flt2SD.m SDadders.m \
x2nextra.m bin2SDul.m tf2pa.m schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m \
schurOneMscale.m qroots.m \
qzsolve.oct spectralfactor.oct bin2SD.oct bin2SPT.oct schurdecomp.oct \
schurexpand.oct schurOneMAPlattice2H.oct schurOneMlattice2Abcd.oct \
complex_zhong_inverse.oct SeDuMi_1_3/"

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
cat > test_A1k0_sd.ok << 'EOF'
A1k0_sd = [   -19712,    32384,   -25792,    28320, ... 
              -23520,    11808 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd.ok"; fail; fi

cat > test_A2k0_sd.ok << 'EOF'
A2k0_sd = [   -22528,    30736,   -26768,    23872, ... 
              -11776 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd.ok"; fail; fi

cat > test_A1k0_sd_sdp.ok << 'EOF'
A1k0_sd_sdp = [   -19584,    32320,   -25760,    28304, ... 
                  -23520,    11808 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_sdp.ok"; fail; fi

cat > test_A2k0_sd_sdp.ok << 'EOF'
A2k0_sd_sdp = [   -23552,    30752,   -26784,    23904, ... 
                  -11776 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_sdp.ok"; fail; fi

cat > test_A1k0_sd_min.ok << 'EOF'
A1k0_sd_min = [   -19584,    32384,   -25728,    28352, ... 
                  -23616,    11808 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k0_sd_min.ok"; fail; fi

cat > test_A2k0_sd_min.ok << 'EOF'
A2k0_sd_min = [   -22560,    30680,   -26880,    23936, ... 
                  -11760 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Initial & 7.52e-06 & -84.0 & & \\
16-bit 4-signed-digit(Ito)  & 1.76e-04 & -45.2 & 44 & 33 \\
16-bit 4-signed-digit(SDP) & 6.00e-01 & -27.5 & 44 & 33 \\
16-bit 4-signed-digit(min) & 1.40e-05 & -75.6 & 43 & 32 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test"

diff -Bb test_A1k0_sd.ok $nstr"_A1k0_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k0_sd.ok"; fail; fi

diff -Bb test_A2k0_sd.ok $nstr"_A2k0_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k0_sd.ok"; fail; fi

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

