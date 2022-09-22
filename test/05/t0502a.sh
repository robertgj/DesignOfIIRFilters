#!/bin/sh

prog=yalmip_complex_test.m
depends="test/yalmip_complex_test.m test_common.m"

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
Linear matrix variable 3x3 (full, complex, 6 variables)
Coeffiecient range: 1 to 1


Using sedumi

Linear matrix variable 9x1 (full, complex, 5 variables)
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SeDuMi)
ans = 0
Z1 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t1 = 2.1048
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28269,0.78269]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SeDuMi)
ans = 0
Z2 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t2 = 1.4508
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28269,0.78269]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SeDuMi)
ans = 0
Z3 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t3 = 1.4508
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28269,0.78269]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SeDuMi)
ans = 0
Z4 =
   4.2826 +      0i   0.8079 + 1.7341i   2.5574 - 0.7937i
   0.8079 - 1.7341i   4.2826 +      0i   0.8079 + 1.7341i
   2.5574 + 0.7937i   0.8079 - 1.7341i   4.2826 +      0i

t4 = 2.1048
ans = Successfully solved (SeDuMi)
ans = 0
Z5 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t5 = 1.4508


Using sdpt3

Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [-0.28269,-0.78269]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SDPT3)
ans = 0
Z1 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t1 = 2.1048
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28268,0.78268]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SDPT3)
ans = 0
Z2 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t2 = 1.4508
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28268,0.78268]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SDPT3)
ans = 0
Z3 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t3 = 1.4508
Linear matrix variable 9x1 (full, complex, 5 variables)
Values in range [0.28268,0.78268]
Coeffiecient range: 0.8 to 4
ans = Successfully solved (SDPT3)
ans = 0
Z4 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t4 = 2.1048
ans = Successfully solved (SDPT3)
ans = 0
Z5 =
   4.2827 +      0i   0.8079 + 1.7342i   2.5574 - 0.7938i
   0.8079 - 1.7342i   4.2827 +      0i   0.8079 + 1.7342i
   2.5574 + 0.7938i   0.8079 - 1.7342i   4.2827 +      0i

t5 = 1.4508
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

