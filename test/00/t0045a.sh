#!/bin/sh

prog=fixResultNaN_test.m

depends="fixResultNaN_test.m \
test_common.m print_polynomial.m print_pole_zero.m fixResultNaN.m"
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
X =  NaN
X = 0
X =
     1   NaN     2

X =
   1   0   2

X =
     1   NaN     2
   NaN     3     4

X =
   1   0   2
   0   3   4

X =
ans(:,:,1) =
   NaN     1     1
     1     1     1
     1   NaN     1
ans(:,:,2) =
   1   1   1
   1   1   1
   1   1   1
ans(:,:,3) =
     1   NaN     1
     1     1     1
     1     1     1

X =
ans(:,:,1) =
   0   1   1
   1   1   1
   1   0   1
ans(:,:,2) =
   1   1   1
   1   1   1
   1   1   1
ans(:,:,3) =
   1   0   1
   1   1   1
   1   1   1

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
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

