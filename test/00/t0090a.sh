#!/bin/sh

prog=tarczynski_parallel_allpass_delay_test.m
depends="tarczynski_parallel_allpass_delay_test.m \
test_common.m print_polynomial.m print_pole_zero.m"
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
cat > test_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,  -0.5220966564,   0.3616274121,   0.1867305290, ... 
          0.0318254621,  -0.0498514036,  -0.0543930474,  -0.0165333545, ... 
          0.0215879166,   0.0367012865,   0.0300055775,   0.0153331903, ... 
          0.0043649745 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m tarczynski_parallel_allpass_delay_test_Da0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

#
# this much worked
#
pass

