#!/bin/sh

prog=tarczynski_bandpass_test.m

depends="test/tarczynski_bandpass_test.m test_common.m print_polynomial.m \
print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m qroots.m qzsolve.oct"

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
cat > test_x.ok << 'EOF'
Ux=2,Vx=2,Mx=18,Qx=8,Rx=2
x = [  -0.0054032517, ...
       -0.9941190066,   1.2185531517, ...
       -0.3154599280,   0.4791065524, ...
        0.7333163003,   0.8754117705,   1.0779108023,   1.0891347497, ... 
        1.0942203517,   1.1305437456,   1.1552377381,   1.3561456809, ... 
        1.5182829788, ...
        2.0359196298,   1.7365890132,   1.6616831646,   0.2473016045, ... 
        2.7731975807,   2.0118928405,   2.3859713817,   0.8708138413, ... 
        1.1945826549, ...
        0.6490204799,   0.6538757658,   0.7944908671,   0.8381748457, ...
        1.6574881523,   2.1984127754,   1.1591003647,   2.6705111495 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x.ok tarczynski_bandpass_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x.ok"; fail; fi


#
# this much worked
#
pass

