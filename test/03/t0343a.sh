#!/bin/sh

name=schurOneMPAlattice_socp_slb_bandpass_hilbert_test
prog=$name".m"
depends="schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef.m \
test_common.m \
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
A1k = [  -0.4137992066,   0.6146452667,   0.4770921375,  -0.5062135299, ... 
          0.7068124703,  -0.3011329750,  -0.0649481604,   0.3692305201, ... 
         -0.2554532925,   0.0900536251 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [ -1, -1,  1,  1, ... 
               1,  1,  1, -1, ... 
              -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   0.9741492608,   0.6272704652,   1.2839941718,   0.7639621552, ... 
          1.3342755397,   0.5530003014,   0.7545515838,   0.8052585123, ... 
          1.1864194944,   0.9136586449 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [  -0.7699294784,   0.7239281377,   0.4452723216,  -0.5756413314, ... 
          0.7314344444,  -0.2536323394,  -0.0687480862,   0.3763450252, ... 
         -0.2342722167,   0.1058690378 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [ -1, -1,  1, -1, ... 
              -1,  1, -1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   1.1824573625,   0.4263222477,   1.0653357564,   0.6600116155, ... 
          0.3425227606,   0.8696956663,   1.1271351476,   1.0521360630, ... 
          0.7082399875,   0.8991843045 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m $name"_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A1epsilon_coef.m $name"_A1epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon_coef.m"; fail; fi

diff -Bb test_A1p_coef.m $name"_A1p_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1p_coef.m"; fail; fi

diff -Bb test_A2k_coef.m $name"_A2k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi

diff -Bb test_A2epsilon_coef.m $name"_A2epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon_coef.m"; fail; fi

diff -Bb test_A2p_coef.m $name"_A2p_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2p_coef.m"; fail; fi

#
# this much worked
#
pass

