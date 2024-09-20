#!/bin/sh

prog=schurOneMAPlatticePipelined2Abcd_test.m
depends="test/schurOneMAPlatticePipelined2Abcd_test.m test_common.m \
schurOneMAPlatticePipelined2Abcd.m schurOneMlatticePipelined2Abcd.m \
tf2schurOneMlattice.m qroots.m schurOneMscale.m \
schurdecomp.oct schurexpand.oct qzsolve.oct Abcd2tf.oct"

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
k is empty!

Testing Nk=1

Testing Nk=2

Testing Nk=3

Testing Nk=4

Testing Nk=5

Testing Nk=6

Testing Nk=7

Testing Nk=8

Testing Nk=9

Testing Nk=10

Testing Nk=11
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. .
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

