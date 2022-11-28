#!/bin/sh

prog=bitflip_schurOneMPAlattice_bandpass_test.m

depends="test/bitflip_schurOneMPAlattice_bandpass_test.m test_common.m \
bitflip_bandpass_test_common.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef.m \
print_polynomial.m schurOneMPAlattice2tf.m tf2pa.m \
schurOneMPAlattice_cost.m tf2schurOneMlattice.m Abcd2tf.m \
schurOneMscale.m flt2SD.m x2nextra.m qroots.m SDadders.m \
schurOneMPAlattice_allocsd_Lim.m schurOneMPAlattice_allocsd_Ito.m \
schurOneMAPlattice2Abcd.m H2Asq.m H2T.m bin2SDul.m \
schurOneMPAlatticeEsq.m schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m \
schurdecomp.oct schurexpand.oct bitflip.oct bin2SD.oct spectralfactor.oct \
schurOneMlattice2Abcd.oct qzsolve.oct complex_zhong_inverse.oct bin2SPT.oct \
schurOneMAPlattice2H.oct"

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
cat > test_A1k_bf.ok << 'EOF'
A1k_bf = [      -56,      106,        9,      -42, ... 
                 70,      -24,      -24,       56, ... 
                -36,       21 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_bf.ok"; fail; fi

cat > test_A2k_bf.ok << 'EOF'
A2k_bf = [      -98,      111,        4,      -48, ... 
                 72,      -13,      -18,       55, ... 
                -40,       19 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_bf.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 1.0870\\
8-bit rounded & 1.8517\\
8-bit rounded with bit-flipping & 1.6093\\
8-bit 2-signed-digit & 10.1625 \\ 
8-bit 2-signed-digit with bit-flipping & 9.1437\\
8-bit 2-signed-digit(Lim alloc.) & 16.8760\\
8-bit 2-signed-digit(Lim alloc.) with bit-flipping & 9.8041\\
8-bit 2-signed-digit(Ito alloc.) & 7.2216\\
8-bit 2-signed-digit(Ito alloc.) with bit-flipping & 4.1649\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_bf.ok bitflip_schurOneMPAlattice_bandpass_test_A1k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_bf.ok"; fail; fi

diff -Bb test_A2k_bf.ok bitflip_schurOneMPAlattice_bandpass_test_A2k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_bf.ok"; fail; fi

diff -Bb test_cost.ok bitflip_schurOneMPAlattice_bandpass_test_cost.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

