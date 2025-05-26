#!/bin/sh

prog=socp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m
depends="test/socp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2p_coef.m \
test_common.m \
schurOneMPAlattice_allocsd_Lim.m \
schurOneMPAlattice_allocsd_Ito.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m schurOneMPAlatticedAsqdw.m schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m flt2SD.m bin2SDul.m x2nextra.m \
SDadders.m Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
tf2schurOneMlattice.m schurOneMscale.m delayz.m \
bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.oct" 

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
cat > test_A1k_min_coef.m << 'EOF'
A1k_min = [     -928,     1696,     -472,      104, ... 
                1392,     -672,      216,     1072, ... 
                -768,      544 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min_coef.m"; fail; fi

cat > test_A2k_min_coef.m << 'EOF'
A2k_min = [    -1656,     1800,     -608,       32, ... 
                1424,     -608,      224,     1072, ... 
                -740,      552 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min_coef.m"; fail; fi

cat > test_N_min_coef.m << 'EOF'
N_min = [  -0.0019531250,   0.0005672872,   0.0088529673,  -0.0241459676, ... 
            0.0153506339,   0.0200372221,  -0.0438538002,   0.0183324544, ... 
            0.0236509505,  -0.0216184911,   0.0000000000,   0.0216184911, ... 
           -0.0236509505,  -0.0183324544,   0.0438538002,  -0.0200372221, ... 
           -0.0153506339,   0.0241459676,  -0.0088529673,  -0.0005672872, ... 
            0.0019531250 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_min_coef.m"; fail; fi

cat > test_D_min_coef.m << 'EOF'
D_min = [   1.0000000000,  -3.7368698120,   6.8021101742,  -5.2620062118, ... 
           -3.6430193502,  15.3312740119, -18.4619809906,   7.0949470054, ... 
           11.8616989500, -22.8375277384,  17.5256949600,  -1.6953652784, ... 
          -11.0292242829,  13.0121256464,  -6.7535890033,  -0.1968616982, ... 
            3.3582386885,  -2.9751065241,   1.4941999753,  -0.4504863853, ... 
            0.0715942383 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D_min_coef.m"; fail; fi


#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test"

diff -Bb test_A1k_min_coef.m $nstr"_A1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_min_coef.m"; fail; fi

diff -Bb test_A2k_min_coef.m $nstr"_A2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_min_coef.m"; fail; fi

diff -Bb test_N_min_coef.m $nstr"_N_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_min_coef.m"; fail; fi

diff -Bb test_D_min_coef.m $nstr"_D_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D_min_coef.m"; fail; fi


#
# this much worked
#
pass

