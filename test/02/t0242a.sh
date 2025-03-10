#!/bin/sh

prog=tarczynski_pink_test.m

depends="test/tarczynski_pink_test.m test_common.m delayz.m WISEJ.m tf2Abcd.m \
print_polynomial.m qroots.oct \
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
cat > test.N0.ok << 'EOF'
N0 = [   0.0255851293,   0.0289174782,   0.0351132935,   0.0414228043, ... 
         0.0728917286,   0.2409301197,   0.0480459047,  -0.0053670832, ... 
        -0.0261923995,  -0.0371426897,  -0.0441734173,  -0.0137173714 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.N0.ok"; fail; fi

cat > test.D0.ok << 'EOF'
D0 = [   1.0000000000,  -0.0471192951,  -0.0997042034,  -0.1305290137, ... 
        -0.1285546872,  -0.1745894781,  -0.0212445182,   0.0163377590, ... 
         0.0036871822,  -0.0016155977,  -0.0012352480,  -0.0045224304 ]';
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

