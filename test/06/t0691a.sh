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
N0 = [  -0.0030989965,   0.0026776291,   0.0006259373,  -0.0056058101, ... 
        -0.0016952273,   0.0025746883,   0.0045055771,   0.0052586494, ... 
        -0.0016106727,  -0.0051472596,  -0.0028888517,   0.0018480507 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -2.3788690545,   2.9921088880,  -1.0919047980, ... 
        -1.5517653107,   2.7622996722,  -1.0722537763,  -1.2015983032, ... 
         2.2617864936,  -1.5818913769,   0.6285200756,  -0.0851292818 ]';
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
