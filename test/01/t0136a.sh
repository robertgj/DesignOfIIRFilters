#!/bin/sh

prog=tf2Abcd_test.m
depends="tf2Abcd_test.m test_common.m tf2Abcd.m"

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
fc = 0.050000
n =
   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =
   1.0000  -2.3741   1.9294  -0.5321

Aa =
        0   1.0000        0
        0        0   1.0000
   0.5321  -1.9294   2.3741

ba =
   0
   0
   1

ca =
   4.4403e-03   3.1029e-03   1.5575e-02

da = 2.8982e-03
Ab =
   0   1   0
   0   0   1
   0   0   0

bb =
   0
   0
   1

cb =
   2.8982e-03   8.6946e-03   8.6946e-03

db = 2.8982e-03
Ac =
        0   1.0000        0
        0        0   1.0000
   0.5321  -1.9294   2.3741

bc =
   0
   0
   1

cc =
   0.5321  -1.9294   2.3741

dc = 1
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

