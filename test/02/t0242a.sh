#!/bin/sh

prog=tarczynski_pink_test.m

depends="test/tarczynski_pink_test.m test_common.m WISEJ.m tf2Abcd.m \
print_polynomial.m"
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
N0 = [   0.0256016303,   0.0280770819,   0.0327402002,   0.0372190965, ... 
         0.0672217223,   0.2336897741,   0.0348827355,  -0.0241715119, ... 
        -0.0431222183,  -0.0434233623,  -0.0366307111,   0.0063174581 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.0797284097,  -0.1533554193,  -0.1827381963, ... 
        -0.1440628003,  -0.1461993301,   0.0724190261,  -0.0027460384, ... 
         0.0022073326,  -0.0030866218,  -0.0011913505,  -0.0046061689 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_pink_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_pink_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok-Bb"; fail; fi


#
# this much worked
#
pass

