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
Da0 = [   1.0000000000,   0.6938010235,  -0.1800215045,  -0.2064703124, ... 
         -0.2152729721,  -0.2125653244,   0.0995944623,  -0.0258296302, ... 
         -0.0504420036,   0.0450010457,  -0.0218357432,   0.0093560144 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.5367204146,  -0.4262653568,  -0.2700896652, ... 
         -0.0842711288,  -0.0747978638,   0.1439048199,  -0.0576489231, ... 
         -0.0524404346,   0.0815241684,  -0.0185463006,  -0.0045928338 ]';
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

