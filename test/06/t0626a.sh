#!/bin/sh

prog=tarczynski_lowpass_differentiator_alternate_test.m

depends="test/tarczynski_lowpass_differentiator_alternate_test.m test_common.m \
delayz.m WISEJ.m tf2Abcd.m print_polynomial.m print_pole_zero.m"

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
N0 = [   0.0039359066,  -0.0112249220,   0.0030826172,   0.0186095531, ... 
        -0.0147426795,  -0.0154904328,   0.0060401177,   0.0265625824, ... 
         0.0362541610,   0.0349904584,   0.0457076604,   0.0250998774 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -1.9104158148,   1.8456686876,   0.1545573719, ... 
        -2.4410691451,   2.9194442498,  -1.3370107729,  -0.6004843431, ... 
         1.3672608432,  -0.9980098036,   0.3858541176,  -0.0678526812 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_lowpass_differentiator_alternate_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_lowpass_differentiator_alternate_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok -Bb"; fail; fi

#
# this much worked
#
pass

