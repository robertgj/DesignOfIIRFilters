#!/bin/sh

prog=tarczynski_allpass2ndOrderCascade_test.m
depends="test/tarczynski_allpass2ndOrderCascade_test.m allpass2ndOrderCascade.m \
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
ab0 = [  -0.6469396958,  -0.9442359889,   0.4869510459,  -0.9856762391, ... 
          0.7229824806,  -0.9362640256,   0.6403280670,  -1.0335980403, ... 
          0.4006386660,  -1.1719209617,   0.8938686168 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab0_coef.m"; fail; fi

cat > test_flat_ab0_coef.m << 'EOF'
ab0 = [   0.5574786686,  -1.3238047258,   0.5314075236,  -0.3298615375, ... 
          0.6070075088,   1.7636609799,   0.7759851766,   0.0314912622, ... 
         -0.4451351017,   0.1310771125,   0.1808946364,   0.2479358993, ... 
         -0.6270124578,   1.1080896773,   0.2565273540,   1.0151129338, ... 
          0.1732037397,  -0.9013120848,   0.4015853662,  -0.3188465339, ... 
          0.5135913754,  -0.8602904189,   0.4806358889 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_ab0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

strn="tarczynski_allpass2ndOrderCascade_test"

diff -Bb test_ab0_coef.m $strn"_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ab0_coef.m"; fail; fi

diff -Bb test_flat_ab0_coef.m $strn"_flat_delay_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_ab0_coef.m"; fail; fi

#
# this much worked
#
pass

