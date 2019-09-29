#!/bin/sh

name=schurOneMPAlattice_socp_slb_bandpass_hilbert_test
prog=$name".m"
depends="schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m test_common.m \
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
 qroots.m qzsolve.oct SeDuMi_1_3/"

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
A1k = [  -0.4135128139,   0.6145035499,   0.4781510544,  -0.5073774741, ... 
          0.7062456961,  -0.3020664345,  -0.0652837453,   0.3701314169, ... 
         -0.2539503510,   0.0898021711 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [ -1, -1,  1,  1, ... 
               1,  1,  1, -1, ... 
              -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   0.9690920710,   0.6242297019,   1.2774789123,   0.7590436235, ... 
          1.3277631562,   0.5509243248,   0.7524912897,   0.8033304513, ... 
          1.1848145223,   0.9138902905 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [  -0.7696098251,   0.7238401764,   0.4472799864,  -0.5760749267, ... 
          0.7310452697,  -0.2546367929,  -0.0685664569,   0.3774782546, ... 
         -0.2334476785,   0.1049279036 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [ -1, -1,  1, -1, ... 
              -1,  1, -1,  1, ... 
               1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   1.1887183273,   0.4289159291,   1.0716190521,   0.6622420343, ... 
          0.3434573899,   0.8713396651,   1.1304790502,   1.0554500548, ... 
          0.7095329593,   0.9000404715 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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

