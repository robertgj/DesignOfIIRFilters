#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="tarczynski_ex2_standalone_test.m test_common.m \
WISEJ.m tf2Abcd.m print_polynomial.m"

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
cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,   1.1782161709,   0.2453844907 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.N0 << 'EOF'
N0 = [   0.0055318290,   0.0168954222,   0.0074759427,  -0.0015204343, ... 
        -0.0019732313,   0.0069425737,   0.0033984642,  -0.0102840762, ... 
        -0.0055109661,   0.0171241295,   0.0104434225,  -0.0353406488, ... 
        -0.0284855289,   0.1348455852,   0.4155099983,   0.6323682462, ... 
         0.6374954584,   0.4464522836,   0.1789073550,  -0.0679303239, ... 
         0.2506267859,  -0.3305116532,   0.2960033061,  -0.1721616224, ... 
         0.0604569743 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.D0 tarczynski_ex2_standalone_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.N0 tarczynski_ex2_standalone_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

#
# this much worked
#
pass

