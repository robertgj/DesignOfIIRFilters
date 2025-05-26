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
A1k_min = [     -816,     1328,     1024,    -1068, ... 
                1360,     -640,      -64,      776, ... 
                -542,      316 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min_coef.m"; fail; fi

cat > test_A2k_min_coef.m << 'EOF'
A2k_min = [    -1530,     1464,     1029,    -1158, ... 
                1376,     -508,        0,      768, ... 
                -568,      320 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min_coef.m"; fail; fi

cat > test_N_min_coef.m << 'EOF'
N_min = [  -0.0009765625,   0.0092279105,  -0.0203790524,   0.0055942630, ... 
            0.0249733618,  -0.0410551000,   0.0202685628,   0.0115383743, ... 
           -0.0352765563,   0.0475626681,   0.0000000000,  -0.0475626681, ... 
            0.0352765563,  -0.0115383743,  -0.0202685628,   0.0410551000, ... 
           -0.0249733618,  -0.0055942630,   0.0203790524,  -0.0092279105, ... 
            0.0009765625 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_min_coef.m"; fail; fi

cat > test_D_min_coef.m << 'EOF'
D_min = [   1.0000000000,  -3.1902575493,   4.7147238205,  -1.7133781624, ... 
           -5.9801970885,  12.9090789584, -11.4678988258,   0.9748102969, ... 
           11.0156003891, -15.0587024940,   9.2028122886,   0.6330733468, ... 
           -6.8360134873,   6.8774025450,  -3.3144580892,   0.0097130576, ... 
            1.3251342124,  -1.1367936110,   0.5479336481,  -0.1590289199, ... 
            0.0241088867 ];
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

