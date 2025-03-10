#!/bin/sh

prog=tarczynski_bandpass_differentiator_test.m
depends="test/tarczynski_bandpass_differentiator_test.m test_common.m delayz.m \
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
N0 = [  -0.0029910043,   0.0046694735,  -0.0018618770,  -0.0039411532, ... 
         0.0007320852,   0.0020922650,   0.0056226539,   0.0005831996, ... 
        -0.0034835354,  -0.0045314416,  -0.0020699882,   0.0047789686 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -3.0840747760,   4.9513299149,  -4.2291097288, ... 
         1.0231548683,   2.2909660398,  -3.0502619848,   1.6189651064, ... 
         0.0741316726,  -0.6338033552,   0.3997940039,  -0.0952863511 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi


#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_bandpass_differentiator_test"

diff -Bb test.N0.ok $nstr"_N0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.N0.ok"; fail; fi

diff -Bb test.D0.ok $nstr"_D0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.D0.ok"; fail; fi

#
# this much worked
#
pass
