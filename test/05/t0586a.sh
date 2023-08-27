#!/bin/sh

prog=tarczynski_schurOneMlattice_lowpass_test.m

depends="test/tarczynski_schurOneMlattice_lowpass_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlattice2tf.m \
H2Asq.m H2T.m Abcd2tf.m delayz.m print_polynomial.m \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct complex_zhong_inverse.oct"

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
k1 = [   0.1694610869,   0.1649206878,   0.1812789821,   0.1185725028, ... 
         0.0379073112,   0.0611904408,   0.0583420478,   0.0094098231, ... 
         0.0176090109,   0.0311393381 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1.ok"; fail; fi

cat > test_c1.ok << 'EOF'
c1 = [  -0.0266551956,  -0.0196526223,   0.0329408225,   0.1316258978, ... 
         0.2276906181,   0.2359888551,   0.1662193394,   0.0636658165, ... 
        -0.0090504107,  -0.0295203754,  -0.0180490760 ];
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
