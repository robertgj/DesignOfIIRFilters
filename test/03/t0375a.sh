#!/bin/sh

prog=saramakiFAvNewton_test.m
depends="test/saramakiFAvNewton_test.m test_common.m saramakiFAvNewton.m \
saramakiFAv.m local_max.m qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
n = 6
m = 5
fp = 0.1000
fs = 0.2000
dBap = 0.010000
z =
   0.2742 + 0.9617i
   0.2742 - 0.9617i
  -0.1047 + 0.9945i
  -0.1047 - 0.9945i
  -1.0000 +      0i

p =
   0.6930 + 0.6014i
   0.6930 - 0.6014i
   0.6421 + 0.4098i
   0.6421 - 0.4098i
   0.6298 + 0.1464i
   0.6298 - 0.1464i

K = 3.3298e-03
dBas = 67.452
iter = 6
b =
 Columns 1 through 6:
            0   3.3298e-03   2.2013e-03   5.1487e-03   5.1487e-03   2.2013e-03
 Column 7:
   3.3298e-03

a =
   1.0000  -3.9300   6.9843  -7.0362   4.2029  -1.4039   0.2043

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
