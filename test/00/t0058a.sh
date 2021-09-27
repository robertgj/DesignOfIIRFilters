#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="tarczynski_ex2_standalone_test.m test_common.m \
WISEJ.m tf2Abcd.m print_polynomial.m"

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
cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,   1.1782058113,   0.2453760924 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.N0 << 'EOF'
N0 = [   0.0055314087,   0.0168955002,   0.0074740808,  -0.0015220044, ... 
        -0.0019754114,   0.0069413192,   0.0033977978,  -0.0102847749, ... 
        -0.0055112028,   0.0171243890,   0.0104433539,  -0.0353403265, ... 
        -0.0284864347,   0.1348461377,   0.4155093432,   0.6323666997, ... 
         0.6374907525,   0.4464469001,   0.1789027643,  -0.0679322102, ... 
         0.2506269157,  -0.3305099074,   0.2960009525,  -0.1721595489, ... 
         0.0604548534 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.D0 tarczynski_ex2_standalone_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.N0 tarczynski_ex2_standalone_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

#
# this much worked
#
pass

