#!/bin/sh

prog=tarczynski_parallel_allpass_delay_test.m
depends="tarczynski_parallel_allpass_delay_test.m \
test_common.m print_polynomial.m print_pole_zero.m"
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
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,  -0.5293689000,   0.3581214229,   0.1868454284, ... 
          0.0310301152,  -0.0571095850,  -0.0703708295,  -0.0384386546, ... 
         -0.0003605657,   0.0199157597,   0.0202940648,   0.0113549188, ... 
          0.0034443544 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da1_coef.m tarczynski_parallel_allpass_delay_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

#
# this much worked
#
pass

