#!/bin/sh

prog=saramakiFAvNewton_test.m
depends="saramakiFAvNewton_test.m test_common.m saramakiFAvNewton.m \
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
n =  6
m =  5
fp =  0.10000
fs =  0.20000
dBap =  0.010000
z =

   0.27418 + 0.96168i
   0.27418 - 0.96168i
  -0.10473 + 0.99450i
  -0.10473 - 0.99450i
  -1.00000 + 0.00000i

p =

   0.69304 + 0.60140i
   0.69304 - 0.60140i
   0.64214 + 0.40980i
   0.64214 - 0.40980i
   0.62984 + 0.14642i
   0.62984 - 0.14642i

K =  0.0033298
dBas =  67.452
iter =  6
b =

   0.0033298   0.0022013   0.0051487   0.0051487   0.0022013   0.0033298

a =

   1.00000  -3.93003   6.98428  -7.03615   4.20291  -1.40391   0.20429

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
