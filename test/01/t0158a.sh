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
ab0 = [  -0.6834412559,  -1.0028021872,   0.8036053504,  -0.8029903675, ... 
          0.4373826021,  -0.9089460566,   0.4134276037,  -1.0865750534, ... 
          0.8753916168,  -1.0437738151,   0.6735669080 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab0_coef.m"; fail; fi

cat > test_flat_ab0_coef.m << 'EOF'
ab0 = [   0.7541092137,   1.7563184840,   0.7720899206,  -0.1921961930, ... 
         -0.3529327598,  -1.3145517987,   0.5363221360,  -0.3631250055, ... 
          0.5812008683,   0.3060487944,   0.2067086314,  -0.2609510407, ... 
         -0.1466372189,  -0.4481585714,   0.4936699178,   1.6597508703, ... 
          0.6892136278,  -0.4865613310,   0.0392254583,  -0.9712072344, ... 
          0.5447285506,   0.9121130789,   0.0283734673 ]';
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

