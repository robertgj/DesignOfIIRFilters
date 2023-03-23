#!/bin/sh

prog=schurOneMPAlattice_socp_slb_lowpass_test.m
depends="test/schurOneMPAlattice_socp_slb_lowpass_test.m test_common.m \
../tarczynski_parallel_allpass_test_flat_delay_Da0_coef.m \
../tarczynski_parallel_allpass_test_flat_delay_Db0_coef.m \
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
schurOneMPAlattice_socp_slb_lowpass_plot.m \
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
A1k = [   0.7708884723,  -0.0881113352,  -0.2676988107,  -0.0638149974, ... 
         -0.0591391496,   0.2444844859,  -0.1442540300,  -0.0042931090, ... 
          0.1646157559,  -0.1595339245,   0.0537213303 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [  1,  1,  1,  1, ... 
               1, -1,  1,  1, ... 
               1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   1.0931104443,   0.3931804442,   0.4294945602,   0.5650941863, ... 
          0.6023834809,   0.6391265598,   0.8202758314,   0.9485248423, ... 
          0.9526057416,   0.8067983551,   0.9476471036 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [   0.3876343601,  -0.2734688172,   0.1867648662,   0.1638998031, ... 
         -0.0461823074,   0.0417459541,  -0.2010119927,   0.1801872215, ... 
          0.0055480902,  -0.1784785436,   0.1504874613,  -0.0547333984 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [  1,  1,  1, -1, ... 
               1, -1, -1, -1, ... 
              -1, -1, -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   1.0555436354,   0.7012035013,   0.9283486367,   0.7684875395, ... 
          0.9067038601,   0.9495907232,   0.9900954019,   0.8075575875, ... 
          0.9689282408,   0.9743189376,   0.8134853936,   0.9466856796 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m schurOneMPAlattice_socp_slb_lowpass_test_A1k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A1epsilon_coef.m \
     schurOneMPAlattice_socp_slb_lowpass_test_A1epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon_coef.m"; fail; fi

diff -Bb test_A1p_coef.m schurOneMPAlattice_socp_slb_lowpass_test_A1p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1p_coef.m"; fail; fi

diff -Bb test_A2k_coef.m schurOneMPAlattice_socp_slb_lowpass_test_A2k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi

diff -Bb test_A2epsilon_coef.m \
     schurOneMPAlattice_socp_slb_lowpass_test_A2epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon_coef.m"; fail; fi

diff -Bb test_A2p_coef.m schurOneMPAlattice_socp_slb_lowpass_test_A2p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2p_coef.m"; fail; fi

#
# this much worked
#
pass

