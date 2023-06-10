#!/bin/sh

prog=bitflip_schurOneMPAlattice_bandpass_test.m

depends="test/bitflip_schurOneMPAlattice_bandpass_test.m test_common.m delayz.m \
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
A1k_bf = [      -50,       87,       63,      -67, ... 
                 78,      -29,      -22,       56, ... 
                -36,       20 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_bf.ok"; fail; fi

cat > test_A2k_bf.ok << 'EOF'
A2k_bf = [      -96,       96,       62,      -73, ... 
                 80,      -18,      -16,       55, ... 
                -40,       19 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_bf.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 1.0852\\
8-bit rounded & 1.9823\\
8-bit rounded with bit-flipping & 1.6756\\
8-bit 2-signed-digit & 8.2926 \\ 
8-bit 2-signed-digit with bit-flipping & 6.3880\\
8-bit 2-signed-digit(Lim alloc.) &    Inf\\
8-bit 2-signed-digit(Lim alloc.) with bit-flipping & 16.2185\\
8-bit 2-signed-digit(Ito alloc.) & 4.4997\\
8-bit 2-signed-digit(Ito alloc.) with bit-flipping & 4.4997\\
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

