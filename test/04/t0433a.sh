#!/bin/sh

prog=chebychevU_test.m

depends="chebychevU_test.m test_common.m print_polynomial.m \
chebychevU.m chebychevP.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
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

#
# the output should look like this
#
cat > test.ok << 'EOF'
U1 = [      2,      0 ];
U0 = [      1 ];
U2 = [      4,      0,     -1 ];
U1 = [      2,      0 ];
U3 = [      8,      0,     -4,      0 ];
U2 = [      4,      0,     -1 ];
U4 = [     16,      0,    -12,      0, ... 
            1 ];
U3 = [      8,      0,     -4,      0 ];
U5 = [     32,      0,    -32,      0, ... 
            6,      0 ];
U4 = [     16,      0,    -12,      0, ... 
            1 ];
U6 = [     64,      0,    -80,      0, ... 
           24,      0,     -1 ];
U5 = [     32,      0,    -32,      0, ... 
            6,      0 ];
U7 = [    128,      0,   -192,      0, ... 
           80,      0,     -8,      0 ];
U6 = [     64,      0,    -80,      0, ... 
           24,      0,     -1 ];
U8 = [    256,      0,   -448,      0, ... 
          240,      0,    -40,      0, ... 
            1 ];
U7 = [    128,      0,   -192,      0, ... 
           80,      0,     -8,      0 ];
U9 = [    512,      0,  -1024,      0, ... 
          672,      0,   -160,      0, ... 
           10,      0 ];
U8 = [    256,      0,   -448,      0, ... 
          240,      0,    -40,      0, ... 
            1 ];
U10 = [   1024,      0,  -2304,      0, ... 
          1792,      0,   -560,      0, ... 
            60,      0,     -1 ];
U9 = [    512,      0,  -1024,      0, ... 
          672,      0,   -160,      0, ... 
           10,      0 ];
U11 = [   2048,      0,  -5120,      0, ... 
          4608,      0,  -1792,      0, ... 
           280,      0,    -12,      0 ];
U10 = [   1024,      0,  -2304,      0, ... 
          1792,      0,   -560,      0, ... 
            60,      0,     -1 ];
U12 = [   4096,      0, -11264,      0, ... 
         11520,      0,  -5376,      0, ... 
          1120,      0,    -84,      0, ... 
             1 ];
U11 = [   2048,      0,  -5120,      0, ... 
          4608,      0,  -1792,      0, ... 
           280,      0,    -12,      0 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 2>&1 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out 
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

