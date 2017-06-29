#!/bin/sh

prog=tarczynski_allpass_phase_shift_test.m
depends="tarczynski_allpass_phase_shift_test.m test_common.m print_polynomial.m"
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
Da1 = [   1.0000000000,  -0.4600541550,   0.3895171433,   0.1750041418, ... 
          0.0054307833,  -0.0609663877,  -0.0421198266,   0.0019489258, ... 
          0.0237825475,   0.0162337004,  -0.0003436796,  -0.0109619904 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da1_coef.m tarczynski_allpass_phase_shift_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi

#
# this much worked
#
pass

