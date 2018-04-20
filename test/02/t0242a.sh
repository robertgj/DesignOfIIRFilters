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
N0 = [   0.0255741848,   0.0278386749,   0.0321481039,   0.0361088386, ... 
         0.0657901764,   0.2319842340,   0.0319190798,  -0.0285615960, ... 
        -0.0468610251,  -0.0439564720,  -0.0332327568,   0.0133589614 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.0879297101,  -0.1670636850,  -0.1960773579, ... 
        -0.1461154685,  -0.1356801929,   0.1031879047,  -0.0101978030, ... 
         0.0012959758,  -0.0039106524,  -0.0018552194,  -0.0051351505 ]';
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

