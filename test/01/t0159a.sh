#!/bin/sh

prog=stability2ndOrderCascade_test.m

depends="stability2ndOrderCascade_test.m \
stability2ndOrderCascade.m test_common.m"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp/SeDuMi_1_3
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

# the output should look like this
#
cat > test.ok << 'EOF'
Ce =
   1   1   0   0
  -1   1   0   0
   0  -1   0   0
   0   0   1   1
   0   0  -1   1
   0   0   0  -1
ee =
   1
   1
   1
   1
   1
   1
Ce =
   1   1   0   0
  -1   1   0   0
   0  -1   0   0
   0   0   1   1
   0   0  -1   1
   0   0   0  -1
ee =
   1
   1
   1
   1
   1
   1
Cel =
   1   1   0   0
  -1   1   0   0
   1  -1   0   0
  -1  -1   0   0
   0  -1   0   0
   0   0   1   1
   0   0  -1   1
   0   0   1  -1
   0   0  -1  -1
   0   0   0  -1
eel =
   1
   1
   1
   1
   1
   1
   1
   1
   1
   1
Co =
   1   0   0   0   0
  -1   0   0   0   0
   0   1   1   0   0
   0  -1   1   0   0
   0   0  -1   0   0
   0   0   0   1   1
   0   0   0  -1   1
   0   0   0   0  -1
eo =
   1
   1
   1
   1
   1
   1
   1
   1
Co =
   1   0   0   0   0
  -1   0   0   0   0
   0   1   1   0   0
   0  -1   1   0   0
   0   0  -1   0   0
   0   0   0   1   1
   0   0   0  -1   1
   0   0   0   0  -1
eo =
   1
   1
   1
   1
   1
   1
   1
   1
Col =
   1   0   0   0   0
  -1   0   0   0   0
   0   1   1   0   0
   0  -1   1   0   0
   0   1  -1   0   0
   0  -1  -1   0   0
   0   0  -1   0   0
   0   0   0   1   1
   0   0   0  -1   1
   0   0   0   1  -1
   0   0   0  -1  -1
   0   0   0   0  -1
eol =
   1
   1
   1
   1
   1
   1
   1
   1
   1
   1
   1
   1
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

