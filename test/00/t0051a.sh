#!/bin/sh

prog=tarczynski_differentiator_test.m

depends="tarczynski_differentiator_test.m test_common.m WISEJ.m tf2Abcd.m \
print_polynomial.m print_pole_zero.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
N0 = [  -0.0033301622,   0.0049842251,  -0.0073918530,   0.0149050168, ... 
        -0.0412778750,   0.3986841865,  -0.3898446868,  -0.0671740294, ... 
         0.1096928157,  -0.1976385751,   0.1919406403,   0.0009944150, ... 
        -0.0148956524 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.2582347026,  -0.4815140505,   0.0529885056, ... 
         0.0016969055,   0.0009654223,   0.0003876028 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_differentiator_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_differentiator_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok -Bb"; fail; fi

#
# this much worked
#
pass

