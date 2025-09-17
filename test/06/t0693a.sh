#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_differentiator_test.m
depends="test/tarczynski_parallel_allpass_bandpass_differentiator_test.m \
test_common.m WISEJ_PA.m delayz.m print_polynomial.m print_pole_zero.m \
qroots.oct"

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
Da0 = [   1.0000000000,   0.8483333962,   0.0835515343,   0.2487532495, ... 
          0.0025197231,  -0.4695585459,  -0.0482919646,   0.1568201710, ... 
         -0.2615088525,  -0.2102477604,   0.0776399024,  -0.0266608277, ... 
         -0.1824856662,   0.0196197814,   0.0135807034,  -0.0741767990 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.5499109269,  -0.3624421681,   0.1734686648, ... 
          0.1764427417,  -0.3896893285,   0.0105184258,   0.2389611027, ... 
         -0.2493956375,  -0.1914868675,   0.1415138464,  -0.0187889918, ... 
         -0.2193491963,   0.0386808567,   0.0404294862,  -0.0781489275 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=tarczynski_parallel_allpass_bandpass_differentiator_test

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

