#!/bin/sh

prog=schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
depends="test/schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m test_common.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m schurOneMscale.m local_max.m tf2pa.m print_polynomial.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m qroots.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct qzsolve.oct Abcd2tf.oct"

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
cat > test_A1k_coef.m << 'EOF'
A1k = [  -0.4554979382,   0.8358996600,  -0.2745129371,   0.1140193719, ... 
          0.6670440074,  -0.3687895076,   0.1854136465,   0.4740114279, ... 
         -0.3579155967,   0.2606467418 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [  1,  1,  1, -1, ... 
              -1, -1, -1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   0.6620001765,   1.0823410698,   0.3235894903,   0.4288957037, ... 
          0.4809345241,   1.0761332955,   0.7307769486,   0.8815587000, ... 
          0.5266098338,   0.7658245646 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [  -0.8097387863,   0.8821439708,  -0.3419413796,   0.0838133063, ... 
          0.6829952246,  -0.3397574166,   0.1933164721,   0.4756708579, ... 
         -0.3433905756,   0.2641334239 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [  1,  1,  1, -1, ... 
              -1, -1, -1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   0.3794659125,   1.1703225816,   0.2928566344,   0.4182053150, ... 
          0.4548569107,   1.0480532208,   0.7357360184,   0.8948458761, ... 
          0.5334030428,   0.7629623046 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr=schurOneMPAlattice_socp_slb_bandpass_hilbert_test

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m $nstr"_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A1epsilon_coef.m $nstr"_A1epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon_coef.m"; fail; fi

diff -Bb test_A1p_coef.m $nstr"_A1p_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1p_coef.m"; fail; fi

diff -Bb test_A2k_coef.m $nstr"_A2k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi

diff -Bb test_A2epsilon_coef.m $nstr"_A2epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon_coef.m"; fail; fi

diff -Bb test_A2p_coef.m $nstr"_A2p_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2p_coef.m"; fail; fi

#
# this much worked
#
pass

