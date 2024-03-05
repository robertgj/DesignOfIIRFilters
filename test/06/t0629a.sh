#!/bin/sh

prog=tarczynski_parallel_allpass_lowpass_differentiator_test.m
depends="test/tarczynski_parallel_allpass_lowpass_differentiator_test.m \
test_common.m WISEJ_PA.m delayz.m print_polynomial.m print_pole_zero.m"
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
Da0 = [   1.0000000000,   0.3293552379,   0.1342448430,   0.1301689296, ... 
          0.1421790787,   0.1028277228,   0.0645259494,   0.0545556418, ... 
          0.0475686056,   0.0338241167,   0.0232220939,   0.0153035935 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -0.3321765291,  -0.0260970209,  -0.0777341690, ... 
         -0.0703766893,  -0.0190360547,  -0.0012137744,  -0.0076449315, ... 
         -0.0049788124,   0.0008263199,   0.0012105634,   0.0029690352, ... 
          0.0124780033 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr=tarczynski_parallel_allpass_lowpass_differentiator_test

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

