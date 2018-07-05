#!/bin/sh

prog=tarczynski_allpass2ndOrderCascade_test.m
depends="tarczynski_allpass2ndOrderCascade_test.m allpass2ndOrderCascade.m \
casc2tf.m test_common.m print_polynomial.m"
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
cat > test_ab1_coef.m << 'EOF'
ab1 = [  -0.6296435763,  -1.0496696577,   0.5481680580,  -0.9786571127, ... 
          0.8240237670,  -1.0529258085,   0.4039167225,  -1.0147463254, ... 
          0.8081349396,  -1.1099274534,   0.8819867923 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_ab1_coef.m tarczynski_allpass2ndOrderCascade_test_ab1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ab1_coef.m"; fail; fi

#
# this much worked
#
pass

