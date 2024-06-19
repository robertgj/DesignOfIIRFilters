#!/bin/sh

prog=tarczynski_lowpass_differentiator_test.m

depends="test/tarczynski_lowpass_differentiator_test.m test_common.m delayz.m \
WISEJ.m tf2Abcd.m print_polynomial.m print_pole_zero.m qroots.m \
qzsolve.oct"

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
N0 = [  -0.0026801253,   0.0092003013,   0.0003529659,  -0.0142796595, ... 
        -0.0028643751,   0.0211557083,   0.0143654399,  -0.0243950992, ... 
        -0.0676552132,  -0.0869992279,  -0.0579124130,  -0.0193059244 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -1.0864790709,   0.4661015440,   0.5532962192, ... 
        -0.6073290537,  -0.2162736559,   0.6595625702,  -0.1533440531, ... 
        -0.5569959523,   0.6914113510,  -0.3677671784,   0.0830706212 ]';
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

