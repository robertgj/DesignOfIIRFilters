#!/bin/sh

prog=tarczynski_schurOneMlattice_lowpass_test.m

depends="test/tarczynski_schurOneMlattice_lowpass_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m schurOneMlatticeEsq.m schurOneMlattice2tf.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m delayz.m print_polynomial.m WISEJ_OneM.m \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct complex_zhong_inverse.oct \
Abcd2tf.oct"

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
cat > test_R1_k0.ok << 'EOF'
k0 = [   0.9797366267,   0.9921874899,   0.5285175573,  -0.2476519228, ... 
        -0.1111173542,   0.5548726172,  -0.5486165969,   0.4404755273, ... 
        -0.2425153711,   0.0696928896 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R1_k0.ok"; fail; fi

cat > test_R1_c0.ok << 'EOF'
c0 = [  -0.0000020588,   0.0000174991,   0.0185346095,   0.2049685029, ... 
         0.2891520906,   0.2550000636,   0.2584754460,  -0.0006482616, ... 
        -0.0684426893,  -0.0360017037,  -0.0085524046 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R1_c0.ok"; fail; fi

cat > test_R2_k0.ok << 'EOF'
k0 = [   0.0000000000,   0.9601875817,   0.0000000000,   0.9921874909, ... 
         0.0000000000,  -0.4326289351,   0.0000000000,   0.2586883485, ... 
         0.0000000000,  -0.0587131413 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R2_k0.ok"; fail; fi

cat > test_R2_c0.ok << 'EOF'
c0 = [  -0.0001456317,   0.0002185896,   0.0006670792,   0.0034554907, ... 
         0.2819630771,   0.3836525774,   0.2101393939,   0.1254827988, ... 
         0.0526442748,  -0.0270894981,  -0.0522209936 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R2_c0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_schurOneMlattice_lowpass_test"

diff -Bb test_R1_k0.ok $nstr"_R1_k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_R1_k0.ok"; fail; fi

diff -Bb test_R1_c0.ok $nstr"_R1_c0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_R1_c0.ok"; fail; fi

diff -Bb test_R2_k0.ok $nstr"_R2_k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_R2_k0.ok"; fail; fi

diff -Bb test_R2_c0.ok $nstr"_R2_c0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_R2_c0.ok"; fail; fi


#
# this much worked
#
pass
