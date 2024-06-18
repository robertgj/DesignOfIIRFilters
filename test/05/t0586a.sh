#!/bin/sh

prog=tarczynski_schurOneMlattice_lowpass_test.m

depends="test/tarczynski_schurOneMlattice_lowpass_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlattice2tf.m \
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
cat > test_k1.ok << 'EOF'
k1 = [   0.7998024158,   0.9899999965,   0.1713037648,  -0.3518824250, ... 
         0.4992843490,  -0.1269572743,  -0.1662404749,   0.2693495405, ... 
        -0.1834885316,   0.0600678853 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1.ok"; fail; fi

cat > test_c1.ok << 'EOF'
c1 = [  -0.0000613759,  -0.0001441428,   0.0219383846,   0.2006921965, ... 
         0.2590788155,   0.3795016901,   0.1632331769,  -0.0011422946, ... 
        -0.0665049716,  -0.0353010514,  -0.0057534422 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1.ok tarczynski_schurOneMlattice_lowpass_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1.ok"; fail; fi

diff -Bb test_c1.ok tarczynski_schurOneMlattice_lowpass_test_c1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c1.ok"; fail; fi


#
# this much worked
#
pass
