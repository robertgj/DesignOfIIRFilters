#!/bin/sh

prog=filter_coefficient_sensitivity_test.m
depends="test/filter_coefficient_sensitivity_test.m \
test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMscale.m \
directFIRsymmetricA.m \
print_polynomial.m delayz.m tf2pa.m tf2Abcd.m H2Asq.m H2T.m Abcd2ng.m KW.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct schurOneMAPlattice2H.oct \
Abcd2H.oct Abcd2tf.oct qroots.oct" 

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
cat > test.n0.ok << 'EOF'
n0 = [   0.0209894754,  -0.0159055715,   0.0197510818,   0.0197510818, ... 
        -0.0159055715,   0.0209894754 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n0.ok"; fail; fi

cat > test.d0.ok << 'EOF'
d0 = [   1.0000000000,  -3.4893036833,   5.5630748041,  -4.8624991170, ... 
         2.3227454901,  -0.4843475226 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d0.ok"; fail; fi

cat > test.k0.ok << 'EOF'
k0 = [  -0.7730675653,   0.9593779044,  -0.8814037135,   0.8266314536, ... 
        -0.4843475226 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k0.ok"; fail; fi

cat > test.epsilon0.ok << 'EOF'
epsilon0 = [   1.0000000000,   1.0000000000,   1.0000000000,   1.0000000000, ... 
               1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon0.ok"; fail; fi

cat > test.c0.ok << 'EOF'
c0 = [   0.0560669836,   0.0952359202,   0.6315001836,   0.0850219299, ... 
         0.1111855074,   0.0209894754 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c0.ok"; fail; fi

cat > test.a0.ok << 'EOF'
a0 = [   1.0000000000,  -1.3980777309,   0.7172567234 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.a0.ok"; fail; fi

cat > test.b0.ok << 'EOF'
b0 = [   1.0000000000,  -2.0912259524,   1.9221216464,  -0.6752777726 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.b0.ok"; fail; fi

cat > test.h0.ok << 'EOF'
h0 = [  -0.0079112781,  -0.0052300593,  -0.0019510562,   0.0044878278, ... 
         0.0110827325,   0.0138738078,   0.0105082134,   0.0022702960, ... 
        -0.0060690041,  -0.0089572117,  -0.0038556818,   0.0064382725, ... 
         0.0149008558,   0.0146536481,   0.0040226943,  -0.0112384944, ... 
        -0.0207616164,  -0.0162583730,   0.0019781888,   0.0234109567, ... 
         0.0325551366,   0.0189845973,  -0.0138994148,  -0.0474555116, ... 
        -0.0558509090,  -0.0203011715,   0.0585188908,   0.1573068461, ... 
         0.2391961447,   0.2709280488,   0.2391961447,   0.1573068461, ... 
         0.0585188908,  -0.0203011715,  -0.0558509090,  -0.0474555116, ... 
        -0.0138994148,   0.0189845973,   0.0325551366,   0.0234109567, ... 
         0.0019781888,  -0.0162583730,  -0.0207616164,  -0.0112384944, ... 
         0.0040226943,   0.0146536481,   0.0149008558,   0.0064382725, ... 
        -0.0038556818,  -0.0089572117,  -0.0060690041,   0.0022702960, ... 
         0.0105082134,   0.0138738078,   0.0110827325,   0.0044878278, ... 
        -0.0019510562,  -0.0052300593,  -0.0079112781 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.h0.ok"; fail; fi


#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="filter_coefficient_sensitivity_test"

diff -Bb test.n0.ok $nstr"_n0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n0.ok"; fail; fi

diff -Bb test.d0.ok $nstr"_d0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d0.ok"; fail; fi

diff -Bb test.k0.ok $nstr"_k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k0.ok"; fail; fi

diff -Bb test.epsilon0.ok $nstr"_epsilon0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.epsilon0.ok"; fail; fi

diff -Bb test.c0.ok $nstr"_c0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c0.ok"; fail; fi

diff -Bb test.a0.ok $nstr"_a0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.a0.ok"; fail; fi

diff -Bb test.b0.ok $nstr"_b0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.b0.ok"; fail; fi

diff -Bb test.h0.ok $nstr"_h0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.h0.ok"; fail; fi

#
# this much worked
#
pass

