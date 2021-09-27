#!/bin/sh

prog=tarczynski_allpass2ndOrderCascade_test.m
depends="tarczynski_allpass2ndOrderCascade_test.m allpass2ndOrderCascade.m \
casc2tf.m test_common.m print_polynomial.m"
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
cat > test_ab0_coef.m << 'EOF'
ab0 = [  -0.5164914994,  -0.8856511874,   0.6117748641,  -0.9844970259, ... 
          0.8018848765,  -0.8762599214,   0.6844422630,  -1.1340041252, ... 
          0.4320188712,  -1.0771249952,   0.8803695792 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_ab0_coef.m tarczynski_allpass2ndOrderCascade_test_ab0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ab0_coef.m"; fail; fi

#
# this much worked
#
pass

