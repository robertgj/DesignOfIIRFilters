#!/bin/sh

prog=schurOneMPAlattice_socp_slb_multiband_test.m

depends="test/schurOneMPAlattice_socp_slb_multiband_test.m \
../tarczynski_parallel_allpass_multiband_test_Da0_coef.m \
../tarczynski_parallel_allpass_multiband_test_Db0_coef.m \
test_common.m delayz.m print_polynomial.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_socp_slb_lowpass_plot.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
H2Asq.m H2T.m H2P.m tf2pa.m qroots.m local_max.m \
complex_zhong_inverse.oct qzsolve.oct Abcd2H.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
schurOneMAPlattice2H.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
cat > test_A1k.ok << 'EOF'
A1k = [   0.7916659480,   0.5438826312,  -0.1908310740,   0.1365136619, ... 
          0.4605408935,   0.1321906683,   0.2097980239,   0.4089322192, ... 
          0.1891823823,  -0.2758256281,   0.1072292330,   0.1218271881, ... 
         -0.1833216266,  -0.1646963993,   0.1193442123,  -0.1312016704, ... 
         -0.2613808427,   0.0586104624,  -0.0704198354,  -0.1707070353 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k.ok"; fail; fi

cat > test_A1epsilon.ok << 'EOF'
A1epsilon = [  1, -1,  1, -1, ... 
               1, -1, -1,  1, ... 
              -1,  1, -1, -1, ... 
              -1,  1,  1,  1, ... 
              -1, -1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon.ok"; fail; fi

cat > test_A2k.ok << 'EOF'
A2k = [   0.7374995686,   0.2597876411,  -0.2804643676,   0.3506624989, ... 
          0.4511062394,  -0.2191645936,  -0.1186798445,   0.3457737858, ... 
          0.2646075191,  -0.2259089237,   0.1158462237,   0.1626620111, ... 
         -0.1134960583,  -0.1173674919,   0.1343300966,  -0.1284566270, ... 
         -0.2690006211,   0.0233592267,  -0.1350203241,  -0.1783460430 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k.ok"; fail; fi

cat > test_A2epsilon.ok << 'EOF'
A2epsilon = [  1, -1,  1, -1, ... 
               1,  1,  1,  1, ... 
              -1,  1,  1,  1, ... 
               1,  1,  1,  1, ... 
              -1, -1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_multiband_test"

diff -Bb test_A1k.ok $nstr"_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k.ok"; fail; fi

diff -Bb test_A1epsilon.ok $nstr"_A1epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon.ok"; fail; fi

diff -Bb test_A2k.ok $nstr"_A2k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k.ok"; fail; fi

diff -Bb test_A2epsilon.ok $nstr"_A2epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon.ok"; fail; fi

#
# this much worked
#
pass

