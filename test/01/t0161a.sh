#!/bin/sh

prog=allpass2ndOrderCascade_socp_sqmag_test.m

depends="test/allpass2ndOrderCascade_socp_sqmag_test.m \
../tarczynski_allpass2ndOrderCascade_test_ab0_coef.m \
test_common.m delayz.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascade_socp.m \
casc2tf.m tf2casc.m qroots.oct"

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
cat > test_a1_coef.m << 'EOF'
a1 = [  -0.6949656665,  -1.2758556915,   0.6784984923,  -1.1578595447, ... 
         0.9076672356 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_b1_coef.m << 'EOF'
b1 = [  -1.2017642733,   0.8111469603,  -1.1485263029,   0.9728748591, ... 
        -1.3547829769,   0.5434986238 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascade_socp_sqmag_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi
diff -Bb test_b1_coef.m allpass2ndOrderCascade_socp_sqmag_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

