#!/bin/sh

prog=tarczynski_phase_equaliser_test.m
depends="tarczynski_phase_equaliser_test.m test_common.m WISEJ_PhaseEq.m iirP.m \
allpassP.m tf2x.m zp2x.m a2tf.m tf2a.m qroots.m qzsolve.oct print_polynomial.m"

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
cat > test_nh4_na4.ok << 'EOF'
a1 = [   0.96081648,   0.49630492,   0.74361849,   0.27143674 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh4_na4.ok"; fail; fi

cat > test_nh4_na3.ok << 'EOF'
a1 = [   0.66091527,   0.93352711,   0.92391194 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh4_na3.ok"; fail; fi

cat > test_nh3_na4.ok << 'EOF'
a1 = [   0.92358904,   0.51356980,   0.76805889,   0.25759083 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh3_na4.ok"; fail; fi

cat > test_nh3_na3.ok << 'EOF'
a1 = [   0.55672024,   0.75876521,   0.83542747 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_nh3_na3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
octave-cli -q $prog
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
