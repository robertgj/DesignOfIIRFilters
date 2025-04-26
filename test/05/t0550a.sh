#!/bin/sh

prog=tarczynski_lowpass_differentiator_test.m

depends="test/tarczynski_lowpass_differentiator_test.m test_common.m delayz.m \
WISEJ.m tf2Abcd.m print_polynomial.m print_pole_zero.m qroots.oct \
"

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
cat > test.N0.ok << 'EOF'
N0 = [  -0.0038995749,   0.0128814540,  -0.0192557591,   0.0140687918, ... 
         0.0051997662,  -0.0236949150,   0.0151976655,   0.0292205204, ... 
        -0.0560062376,  -0.1508573959,  -0.1800922176,  -0.0938936083 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.9264034393,   1.8089065044,  -2.0146510639, ... 
         1.9544707562,  -1.6086081725,   1.1187131246,  -0.6479553283, ... 
         0.3032794320,  -0.1081616811,   0.0258714248,  -0.0027949401 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_lowpass_differentiator_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_lowpass_differentiator_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok -Bb"; fail; fi

#
# this much worked
#
pass

