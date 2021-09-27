#!/bin/sh

prog=schurOneMPAlattice_socp_slb_lowpass_test.m
depends="schurOneMPAlattice_socp_slb_lowpass_test.m test_common.m \
../tarczynski_parallel_allpass_test_Da0_coef.m \
../tarczynski_parallel_allpass_test_Db0_coef.m \
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
A1k = [   0.7708553001,  -0.0881484548,  -0.2675900297,  -0.0638632672, ... 
         -0.0593328770,   0.2446250997,  -0.1442830937,  -0.0044620112, ... 
          0.1646995029,  -0.1595259210,   0.0536804839 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [  1,  1,  1,  1, ... 
               1, -1,  1,  1, ... 
               1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   1.0926101831,   0.3930326361,   0.4293491623,   0.5648366952, ... 
          0.6021381819,   0.6389905122,   0.8202238857,   0.9484929273, ... 
          0.9527345977,   0.8068380320,   0.9476859244 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [   0.3876010782,  -0.2733974816,   0.1868202238,   0.1637829241, ... 
         -0.0461373806,   0.0419429260,  -0.2011619974,   0.1801954423, ... 
          0.0057039675,  -0.1785575739,   0.1504907205,  -0.0546896233 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [  1,  1,  1, -1, ... 
               1, -1, -1, -1, ... 
              -1, -1, -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   1.0557307484,   0.7013552707,   0.9284779813,   0.7685505266, ... 
          0.9066692753,   0.9495117520,   0.9902084283,   0.8075235291, ... 
          0.9688956091,   0.9744380102,   0.8135183988,   0.9467272462 ];
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

