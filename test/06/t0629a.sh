#!/bin/sh

prog=tarczynski_parallel_allpass_lowpass_differentiator_test.m
depends="test/tarczynski_parallel_allpass_lowpass_differentiator_test.m \
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
Da0 = [   1.0000000000,   0.2426702109,   0.1222114699,   0.1960862164, ... 
          0.1178948367,   0.0507360664,   0.1037729498,   0.0766915741, ... 
          0.0111560682,   0.0769260924,   0.0156067498,   0.0227634694 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -0.2164512375,  -0.1278173647,  -0.1237807124, ... 
         -0.0020726566,  -0.0372181627,  -0.0195667842,  -0.0004705834, ... 
         -0.0319113502,   0.0360300779,  -0.0406009321,   0.0276388420, ... 
          0.0125719778 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=tarczynski_parallel_allpass_lowpass_differentiator_test

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

