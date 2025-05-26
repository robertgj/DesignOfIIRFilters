#!/bin/sh

prog=bitflip_schurOneMPAlattice_bandpass_test.m

depends="test/bitflip_schurOneMPAlattice_bandpass_test.m test_common.m delayz.m \
bitflip_bandpass_test_common.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef.m \
print_polynomial.m schurOneMPAlattice2tf.m tf2pa.m \
schurOneMPAlattice_cost.m tf2schurOneMlattice.m \
schurOneMscale.m flt2SD.m x2nextra.m qroots.oct SDadders.m \
schurOneMPAlattice_allocsd_Lim.m schurOneMPAlattice_allocsd_Ito.m \
schurOneMAPlattice2Abcd.m H2Asq.m H2T.m bin2SDul.m \
schurOneMPAlatticeEsq.m schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m \
schurdecomp.oct schurexpand.oct bitflip.oct bin2SD.oct spectralfactor.oct \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct bin2SPT.oct \
schurOneMAPlattice2H.oct Abcd2tf.oct"

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
A1k_bf = [      -50,       84,       67,      -69, ... 
                 82,      -43,       -4,       45, ... 
                -32,       20 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_bf.ok"; fail; fi

cat > test_A2k_bf.ok << 'EOF'
A2k_bf = [      -96,       93,       67,      -75, ... 
                 84,      -33,        2,       44, ... 
                -35,       18 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_bf.ok"; fail; fi

cat > test_A1k_bfsd.ok << 'EOF'
A1k_bfsd = [      -48,       80,       72,      -68, ... 
                   80,      -40,       -4,       48, ... 
                  -32,       24 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_bfsd.ok"; fail; fi

cat > test_A2k_bfsd.ok << 'EOF'
A2k_bfsd = [      -96,       96,       65,      -72, ... 
                   80,      -33,        2,       48, ... 
                  -36,       17 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_bfsd.ok"; fail; fi

cat > test_A1k_bfsdi.ok << 'EOF'
A1k_bfsdi = [      -48,       82,       64,      -68, ... 
                    82,      -40,       -4,       48, ... 
                   -32,       18 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_bfsdi.ok"; fail; fi

cat > test_A2k_bfsdi.ok << 'EOF'
A2k_bfsdi = [      -96,       96,       64,      -76, ... 
                    88,      -32,        0,       44, ... 
                   -32,       16 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_bfsdi.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 1.0878\\
8-bit rounded & 1.9779\\
8-bit rounded with bit-flipping & 1.3743\\
8-bit 2-signed-digit & 8.2848 \\ 
8-bit 2-signed-digit with bit-flipping & 7.3066\\
8-bit 2-signed-digit(Lim alloc.) & 15.3864\\
8-bit 2-signed-digit(Lim alloc.) with bit-flipping & 5.7757\\
8-bit 2-signed-digit(Ito alloc.) & 7.9759\\
8-bit 2-signed-digit(Ito alloc.) with bit-flipping & 4.6859\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_schurOneMPAlattice_bandpass_test";

diff -Bb test_A1k_bf.ok $nstr"_A1k_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_bf.ok"; fail; fi

diff -Bb test_A2k_bf.ok $nstr"_A2k_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_bf.ok"; fail; fi

diff -Bb test_A1k_bfsd.ok $nstr"_A1k_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_bfsd.ok"; fail; fi

diff -Bb test_A2k_bfsd.ok $nstr"_A2k_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_bfsd.ok"; fail; fi

diff -Bb test_A1k_bfsdi.ok $nstr"_A1k_bfsdi_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_bfsdi.ok"; fail; fi

diff -Bb test_A2k_bfsdi.ok $nstr"_A2k_bfsdi_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_bfsdi.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

