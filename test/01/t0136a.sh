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
cat > test.ok << 'EOF'
fc =  0.050000
n =
   0.0028982   0.0086946   0.0086946   0.0028982

d =
   1.00000  -2.37409   1.92936  -0.53208

Aa =
   0.00000   1.00000   0.00000
   0.00000   0.00000   1.00000
   0.53208  -1.92936   2.37409

ba =
   0
   0
   1

ca =
   0.0044403   0.0031029   0.0155752

da =  0.0028982
Ab =
   0   1   0
   0   0   1
  -0  -0  -0

bb =
   0
   0
   1

cb =
   0.0028982   0.0086946   0.0086946

db =  0.0028982
Ac =
   0.00000   1.00000   0.00000
   0.00000   0.00000   1.00000
   0.53208  -1.92936   2.37409

bc =
   0
   0
   1

cc =
   0.53208  -1.92936   2.37409

dc =  1
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

