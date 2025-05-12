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
A1k_min = [     -232,      428,     -143,       60, ... 
                 344,     -191,       94,      242, ... 
                -184,      132 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min_coef.m"; fail; fi

cat > test_A2k_min_coef.m << 'EOF'
A2k_min = [     -416,      449,     -176,       40, ... 
                 351,     -174,       98,      244, ... 
                -176,      136 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min_coef.m"; fail; fi

cat > test_N_min_coef.m << 'EOF'
N_min = [  -0.0039062500,   0.0067537427,  -0.0011031450,  -0.0204655776, ... 
            0.0290610512,  -0.0084715888,  -0.0246030239,   0.0321755776, ... 
           -0.0188701716,   0.0158133977,   0.0000000000,  -0.0158133977, ... 
            0.0188701716,  -0.0321755776,   0.0246030239,   0.0084715888, ... 
           -0.0290610512,   0.0204655776,   0.0011031450,  -0.0067537427, ... 
            0.0039062500 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_min_coef.m"; fail; fi

cat > test_D_min_coef.m << 'EOF'
D_min = [   1.0000000000,  -3.7759552002,   6.9550732601,  -5.5709281433, ... 
           -3.3398954633,  15.3640517767, -19.0860495362,   8.1302717218, ... 
           10.9798350740, -22.6692787151,  18.1424510873,  -2.6687956548, ... 
          -10.2796715090,  12.7838875058,  -6.9717638347,   0.1901433648, ... 
            3.0293621439,  -2.7873503545,   1.4179882463,  -0.4300670568, ... 
            0.0684814453 ];
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

