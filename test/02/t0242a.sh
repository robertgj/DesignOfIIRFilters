#!/bin/sh

prog=tarczynski_pink_test.m

depends="tarczynski_pink_test.m test_common.m WISEJ.m tf2Abcd.m \
print_polynomial.m"
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
cat > test.N0.ok << 'EOF'
N0 = [   0.0255727230,   0.0288032762,   0.0348001020,   0.0408824817, ... 
         0.0722045763,   0.2400816132,   0.0464859733,  -0.0076136919, ... 
        -0.0280519353,  -0.0374767326,  -0.0426679163,  -0.0104789966 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.0515042857,  -0.1065853312,  -0.1367652884, ... 
        -0.1294137212,  -0.1696692574,  -0.0067101612,   0.0127835467, ... 
         0.0030545111,  -0.0020716000,  -0.0016082154,  -0.0048884317 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.D0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.N0.ok tarczynski_pink_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.N0.ok -Bb"; fail; fi

diff -Bb test.D0.ok tarczynski_pink_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff test.D0.ok-Bb"; fail; fi


#
# this much worked
#
pass

