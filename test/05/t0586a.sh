#!/bin/sh

prog=tarczynski_schurOneMlattice_lowpass_test.m

depends="test/tarczynski_schurOneMlattice_lowpass_test.m test_common.m \
WISEJ_OneM.m schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlattice2tf.m \
H2Asq.m H2T.m delayz.m print_polynomial.m \
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
cat > test_k0.ok << 'EOF'
k0 = [   0.7988657680,   0.9921874883,   0.1727400221,  -0.3530360631, ... 
         0.4999041934,  -0.1276767399,  -0.1657406971,   0.2691647248, ... 
        -0.1834806747,   0.0601080043 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0.ok"; fail; fi

cat > test_c0.ok << 'EOF'
c0 = [  -0.0000530236,  -0.0001127314,   0.0218916633,   0.2007890856, ... 
         0.2590051542,   0.3796185143,   0.1630851304,  -0.0011781520, ... 
        -0.0665220258,  -0.0353056180,  -0.0057405830 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k0.ok tarczynski_schurOneMlattice_lowpass_test_k0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0.ok"; fail; fi

diff -Bb test_c0.ok tarczynski_schurOneMlattice_lowpass_test_c0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0.ok"; fail; fi


#
# this much worked
#
pass
