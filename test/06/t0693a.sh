#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_differentiator_test.m
depends="test/tarczynski_parallel_allpass_bandpass_differentiator_test.m \
test_common.m WISEJ_PAB.m delayz.m print_polynomial.m print_pole_zero.m \
qroots.oct \
"

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
Da0 = [   1.0000000000,   0.2443926902,  -0.2763196215,   0.3199897980, ... 
         -0.5763028694,  -0.4388341254,   0.4459797035,  -0.2884586221, ... 
         -0.1531729578,   0.1653494067,  -0.1045185698,   0.0058107930 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.0749472030,  -0.4518592796,   0.3598316945, ... 
         -0.5103063370,  -0.3625056222,   0.5613845576,  -0.2997250370, ... 
         -0.1739282328,   0.2057436379,  -0.1079912063,  -0.0124730746 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr=tarczynski_parallel_allpass_bandpass_differentiator_test

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

