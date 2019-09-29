#!/bin/sh

prog=sparsePOP_test.m

depends="sparsePOP_test.m test_common.m SparsePOP302/ SeDuMi_1_3/"
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

k=1
POP.xVect=
   0.477548 
   0.000000 
   3.500000 

k=2
POP.xVect=
  -0.999990 
   0.999989 
   0.999990 
   0.999990 
   0.999991 
   0.999990 
   0.999991 
   0.999991 
   0.999993 
   0.999994 
   0.999995 
   0.999995 
   0.999995 
   0.999994 
   0.999994 
   0.999994 
   0.999995 
   0.999996 
   0.999997 
   0.999998 
   0.999999 
   1.000000 
   1.000000 
   1.000001 
   1.000001 
   1.000001 
   1.000000 
   1.000000 
   0.999999 
   0.999998 
   0.999997 
   0.999996 
   0.999995 
   0.999993 
   0.999989 
   0.999984 
   0.999974 
   0.999952 
   0.999908 
   0.999817 
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok sparsePOP_test_xVect.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.ok"; fail; fi

#
# this much worked
#
pass
