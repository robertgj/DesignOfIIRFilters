#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="tarczynski_ex2_standalone_test.m test_common.m \
WISEJ.m tf2Abcd.m print_polynomial.m"

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
D0 = [   1.0000000000,   1.1782055247,   0.2453761906 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.N0 << 'EOF'
N0 = [   0.0055320618,   0.0168964837,   0.0074753205,  -0.0015215157, ... 
        -0.0019749902,   0.0069418960,   0.0033977155,  -0.0102842193, ... 
        -0.0055116039,   0.0171241990,   0.0104427562,  -0.0353411253, ... 
        -0.0284877776,   0.1348446063,   0.4155080556,   0.6323659783, ... 
         0.6374906164,   0.4464472313,   0.1789025959,  -0.0679315564, ... 
         0.2506270828,  -0.3305093421,   0.2960012842,  -0.1721597661, ... 
         0.0604551723 ]';
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

