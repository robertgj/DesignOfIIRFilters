#!/bin/sh

prog=tarczynski_pink_test.m

depends="tarczynski_pink_test.m test_common.m WISEJ.m tf2Abcd.m \
print_polynomial.m"
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
cat > test.N0.ok << 'EOF'
N0 = [   0.0255833180,   0.0288297762,   0.0349015365,   0.0410470406, ... 
         0.0724114336,   0.2403758179,   0.0470741306,  -0.0068650125, ... 
        -0.0274731240,  -0.0372626557,  -0.0428914041,  -0.0111321446 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.0499055561,  -0.1044251014,  -0.1351797674, ... 
        -0.1291139857,  -0.1706665191,  -0.0099131791,   0.0133326067, ... 
         0.0032819127,  -0.0019576252,  -0.0016605439,  -0.0046822009 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_pink_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_pink_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok-Bb"; fail; fi


#
# this much worked
#
pass

