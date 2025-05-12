#!/bin/sh

prog=socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.m
depends="test/socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef.m \
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
SDadders.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
tf2schurOneMlattice.m schurOneMscale.m delayz.m \
bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.oct Abcd2tf.oct"

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
A1k_min = [     -816,     1344,      984,    -1059, ... 
                1279,     -432,     -320,      912, ... 
                -592,      320 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min_coef.m"; fail; fi

cat > test_A2k_min_coef.m << 'EOF'
A2k_min = [    -1530,     1496,      984,    -1145, ... 
                1308,     -288,     -256,      896, ... 
                -624,      320 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min_coef.m"; fail; fi

cat > test_N_min_coef.m << 'EOF'
N_min = [   0.0000000000,   0.0076217651,  -0.0177038209,   0.0028777888, ... 
            0.0253404597,  -0.0376496270,   0.0149168106,   0.0159362300, ... 
           -0.0389972792,   0.0506928304,   0.0000000000,  -0.0506928304, ... 
            0.0389972792,  -0.0159362300,  -0.0149168106,   0.0376496270, ... 
           -0.0253404597,  -0.0028777888,   0.0177038209,  -0.0076217651, ... 
            0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_min_coef.m"; fail; fi

cat > test_D_min_coef.m << 'EOF'
D_min = [   1.0000000000,  -3.1335585117,   4.4735724856,  -1.2362004095, ... 
           -6.4373503322,  12.8119385129, -10.4715318470,  -0.5930637826, ... 
           12.2315897932, -15.1270408701,   8.1134869879,   2.1275268368, ... 
           -7.8867437308,   7.1360998546,  -3.0024292795,  -0.4519005212, ... 
            1.6585156662,  -1.2930795511,   0.5951647380,  -0.1670113544, ... 
            0.0244140625 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D_min_coef.m"; fail; fi


#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test"

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

