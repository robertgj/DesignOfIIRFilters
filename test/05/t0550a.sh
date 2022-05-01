#!/bin/sh

prog=tarczynski_lowpass_differentiator_test.m

depends="tarczynski_lowpass_differentiator_test.m test_common.m WISEJ.m \
tf2Abcd.m print_polynomial.m print_pole_zero.m"

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
N0 = [   0.0039515357,  -0.0051255087,  -0.0038857070,   0.0082150397, ... 
         0.0042466082,  -0.0031605021,  -0.0162771476,  -0.0202519597, ... 
        -0.0036001226,   0.0113255056,   0.0169030730,   0.0083909600 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -1.6902149475,   1.4661911310,   0.2155578050, ... 
        -1.8940448880,   2.0254376026,  -0.6989935146,  -0.6656118253, ... 
         1.0586775244,  -0.6899134933,   0.2433807842,  -0.0392817710 ]';
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

