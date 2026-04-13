#!/bin/sh

prog=tarczynski_bandpass_R1_test.m

depends="test/tarczynski_bandpass_R1_test.m test_common.m delayz.m print_polynomial.m \
print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m qroots.oct"

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
cat > test_N0.ok << 'EOF'
N0 = [   0.0000547954,   0.0015973960,  -0.0039353157,   0.0012178726, ... 
         0.0079911246,  -0.0058523115,  -0.0127949401,   0.0151185115, ... 
         0.0108207989,  -0.0205566820,  -0.0101463862,   0.0140837658, ... 
         0.0138642592,   0.0019109289,  -0.0107291195,  -0.0125194930, ... 
         0.0012373696,   0.0103733381,   0.0019620061,  -0.0032388723, ... 
        -0.0003950230 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N0.ok"; fail; fi

cat > test_D0.ok << 'EOF'
D0 = [   1.0000000000,  -5.6165525284,  15.9012163125, -29.9006798169, ... 
        41.3735154697, -44.0983456063,  36.9557849166, -24.4892508583, ... 
        12.7465353318,  -5.0986921860,   1.4885925587,  -0.2814575323, ... 
         0.0288834602,  -0.0070487710,  -0.0010510598,   0.0069969385, ... 
        -0.0000336169,  -0.0066172601,   0.0026912136,   0.0023666249, ... 
        -0.0020564381 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N0.ok tarczynski_bandpass_R1_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N0.ok"; fail; fi

diff -Bb test_D0.ok tarczynski_bandpass_R1_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D0.ok"; fail; fi

#
# this much worked
#
pass

