#!/bin/sh

prog=tarczynski_phase_equaliser_test.m
depends="test/tarczynski_phase_equaliser_test.m test_common.m delayz.m WISEJ_PhaseEq.m iirP.m \
allpassP.m tf2x.m zp2x.m a2tf.m tf2a.m qroots.oct print_polynomial.m"

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
cat > test_nh4_na4.ok << 'EOF'
a1 = [   0.96081644,   0.49630478,   0.74361849,   0.27143678 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh4_na4.ok"; fail; fi

cat > test_nh4_na3.ok << 'EOF'
a1 = [   0.66091529,   0.93352733,   0.92391228 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh4_na3.ok"; fail; fi

cat > test_nh3_na4.ok << 'EOF'
a1 = [   0.92358863,   0.51356932,   0.76805895,   0.25759056 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh3_na4.ok"; fail; fi

cat > test_nh3_na3.ok << 'EOF'
a1 = [   0.55671986,   0.75876445,   0.83542796 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh3_na3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_nh4_na4.ok tarczynski_phase_equaliser_test_nh4_na4_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_nh4_na4.ok"; fail; fi

diff -Bb test_nh4_na3.ok tarczynski_phase_equaliser_test_nh4_na3_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_nh4_na3.ok"; fail; fi

diff -Bb test_nh3_na4.ok tarczynski_phase_equaliser_test_nh3_na4_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_nh3_na4.ok"; fail; fi

diff -Bb test_nh3_na3.ok tarczynski_phase_equaliser_test_nh3_na3_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_nh3_na3.ok"; fail; fi

#
# this much worked
#
pass
