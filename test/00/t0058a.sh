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
D0 = [   1.0000000000,   1.1782203241,   0.2453876453 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.N0 << 'EOF'
N0 = [   0.0055317983,   0.0168958669,   0.0074748142,  -0.0015216467, ... 
        -0.0019754010,   0.0069409304,   0.0033973357,  -0.0102848523, ... 
        -0.0055116383,   0.0171239827,   0.0104432990,  -0.0353397276, ... 
        -0.0284859806,   0.1348456637,   0.4155091524,   0.6323693889, ... 
         0.6374978107,   0.4464557159,   0.1789101850,  -0.0679290640, ... 
         0.2506272246,  -0.3305116740,   0.2960049943,  -0.1721618828, ... 
         0.0604582705 ]';
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

