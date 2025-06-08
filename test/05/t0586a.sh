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
k0 = [   0.9750177576,   0.9921874871,  -0.4167191295,   0.1689065241, ... 
         0.3283877542,  -0.2857446985,   0.1554427152,  -0.0112556238, ... 
        -0.0255052725,   0.0105279314 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R1_k0.ok"; fail; fi

cat > test_R1_c0.ok << 'EOF'
c0 = [  -0.0000112845,  -0.0001728596,   0.0564413961,   0.1905686780, ... 
         0.3003480658,   0.3615690721,   0.1216925624,  -0.0037744910, ... 
        -0.0558581729,  -0.0363735773,  -0.0078268187 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R1_c0.ok"; fail; fi

cat > test_R2_k0.ok << 'EOF'
k0 = [   0.0000000000,   0.9598202848,   0.0000000000,   0.9921874920, ... 
         0.0000000000,  -0.4499980310,   0.0000000000,   0.2779052280, ... 
         0.0000000000,  -0.0664867990 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_R2_k0.ok"; fail; fi

cat > test_R2_c0.ok << 'EOF'
c0 = [  -0.0001499106,   0.0002953431,   0.0007270336,   0.0033021374, ... 
         0.2824465424,   0.3848780419,   0.2108346405,   0.1241361948, ... 
         0.0531309769,  -0.0316764962,  -0.0529980521 ];
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
