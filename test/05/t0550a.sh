#!/bin/sh

prog=tarczynski_lowpass_differentiator_test.m

depends="test/tarczynski_lowpass_differentiator_test.m test_common.m delayz.m WISEJ.m \
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
N0 = [   0.0026816351,  -0.0092012134,  -0.0003547909,   0.0142811534, ... 
         0.0028657639,  -0.0211581417,  -0.0143670756,   0.0243951957, ... 
         0.0676583470,   0.0870062806,   0.0579206352,   0.0193109148 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -1.0863118503,   0.4657654987,   0.5536912994, ... 
        -0.6075511069,  -0.2163137246,   0.6597458862,  -0.1534973411, ... 
        -0.5569374380,   0.6914132571,  -0.3677793787,   0.0830760733 ]';
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

