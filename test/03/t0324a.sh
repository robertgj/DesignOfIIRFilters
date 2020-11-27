#!/bin/sh

prog=schurOneMPAlattice_socp_slb_bandpass_test.m
depends="schurOneMPAlattice_socp_slb_bandpass_test.m test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m \
schurOneMscale.m local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.m qzsolve.oct"

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
A1k = [  -0.7666597804,   0.8667401054,   0.0252095961,  -0.3718472889, ... 
          0.5652033325,  -0.1071060380,  -0.1373512436,   0.4282945944, ... 
         -0.3103535415,   0.1515745427 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [  1,  1, -1,  1, ... 
              -1,  1,  1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   0.3641454523,   1.0019742264,   0.2677098521,   0.2745459635, ... 
          0.4057283252,   0.7697994683,   0.8571804817,   0.9842435480, ... 
          0.6227013820,   0.8583428975 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [  -0.4417700339,   0.8255993520,   0.0573543439,  -0.3256363836, ... 
          0.5450440870,  -0.1927089741,  -0.1833550314,   0.4373452222, ... 
         -0.2825856868,   0.1647448391 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [  1,  1, -1,  1, ... 
              -1, -1,  1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   0.7519814809,   1.2085053288,   0.3735251772,   0.3955996713, ... 
          0.5546526142,   1.0221316716,   0.8409199665,   1.0122680973, ... 
          0.6333386770,   0.8468260055 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A1epsilon_coef.m \
     schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon_coef.m"; fail; fi

diff -Bb test_A1p_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1p_coef.m"; fail; fi

diff -Bb test_A2k_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi

diff -Bb test_A2epsilon_coef.m \
     schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon_coef.m"; fail; fi

diff -Bb test_A2p_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2p_coef.m"; fail; fi

#
# this much worked
#
pass

