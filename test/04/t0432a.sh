#!/bin/sh

prog=chebychevT_test.m

depends="chebychevT_test.m test_common.m print_polynomial.m \
chebychevT.m chebychevP.m"

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
T1 = [      1,      0 ];
T0 = [      1 ];
T2 = [      2,      0,     -1 ];
T1 = [      1,      0 ];
T3 = [      4,      0,     -3,      0 ];
T2 = [      2,      0,     -1 ];
T4 = [      8,      0,     -8,      0, ... 
            1 ];
T3 = [      4,      0,     -3,      0 ];
T5 = [     16,      0,    -20,      0, ... 
            5,      0 ];
T4 = [      8,      0,     -8,      0, ... 
            1 ];
T6 = [     32,      0,    -48,      0, ... 
           18,      0,     -1 ];
T5 = [     16,      0,    -20,      0, ... 
            5,      0 ];
T7 = [     64,      0,   -112,      0, ... 
           56,      0,     -7,      0 ];
T6 = [     32,      0,    -48,      0, ... 
           18,      0,     -1 ];
T8 = [    128,      0,   -256,      0, ... 
          160,      0,    -32,      0, ... 
            1 ];
T7 = [     64,      0,   -112,      0, ... 
           56,      0,     -7,      0 ];
T9 = [    256,      0,   -576,      0, ... 
          432,      0,   -120,      0, ... 
            9,      0 ];
T8 = [    128,      0,   -256,      0, ... 
          160,      0,    -32,      0, ... 
            1 ];
T10 = [    512,      0,  -1280,      0, ... 
          1120,      0,   -400,      0, ... 
            50,      0,     -1 ];
T9 = [    256,      0,   -576,      0, ... 
          432,      0,   -120,      0, ... 
            9,      0 ];
T11 = [   1024,      0,  -2816,      0, ... 
          2816,      0,  -1232,      0, ... 
           220,      0,    -11,      0 ];
T10 = [    512,      0,  -1280,      0, ... 
          1120,      0,   -400,      0, ... 
            50,      0,     -1 ];
T12 = [   2048,      0,  -6144,      0, ... 
          6912,      0,  -3584,      0, ... 
           840,      0,    -72,      0, ... 
             1 ];
T11 = [   1024,      0,  -2816,      0, ... 
          2816,      0,  -1232,      0, ... 
           220,      0,    -11,      0 ];
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

