#!/bin/sh

prog=flt2SD_test.m

depends="flt2SD_test.m test_common.m print_polynomial.m \
flt2SD.m x2nextra.m bin2SDul.m bin2SD.oct"

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
flt2SD:converted x=[0.47804 0.166148 0.301198 0.174448 -0.213256 -0.387277 0.195574 0.231619 -0.336613 0.381189 0.464215 0.241204 0.344518 0.324174 0.354194 -0.170809 ] to y=[0.46875 0.15625 0.3125 0.1875 -0.21875 -0.375 0.1875 0.234375 -0.3125 0.375 0.46875 0.242188 0.375 0.3125 0.375 -0.1875 ], y.*nshift=[60 20 40 24 -28 -48 24 30 -40 48 60 31 48 40 48 -24 ]

testrandSD = [ 0.46875, 0.15625, 0.31250, 0.18750 ]';
flt2SD:converted x=[0.47804 0.166148 0.301198 0.174448 -0.213256 -0.387277 0.195574 0.231619 -0.336613 0.381189 0.464215 0.241204 0.344518 0.324174 0.354194 -0.170809 ] to y=[0.5 0.125 0.25 0.125 -0.21875 -0.375 0.1875 0.234375 -0.34375 0.382812 0.460938 0.242188 0.34375 0.320312 0.351562 -0.171875 ], y.*nshift=[64 16 32 16 -28 -48 24 30 -44 49 59 31 44 41 45 -22 ]

testrandSDarray = [ 0.500, 0.125, 0.250, 0.125 ]';
Caught y1=flt2SD([ 0.1111 ],51,52,1)
Caught y1=flt2SD([ 0.1111 ],52,51,1)
Caught y1=flt2SD([ 0.1111 ],8,9,1)
flt2SD:converted x=[0.1111 ] to y=[-0 ], y.*nshift=[0 ]

Caught y1=flt2SD([ 0.1111 ],0,8,1)
flt2SD:converted x=[0 ] to y=[0 ], y.*nshift=[0 ]

flt2SD:converted x=[0 ] to y=[0 ], y.*nshift=[0 ]

flt2SD:converted x=[1 ] to y=[1 ], y.*nshift=[128 ]

flt2SD:converted x=[1 ] to y=[1 ], y.*nshift=[128 ]

flt2SD:converted x=[-1 ] to y=[-1 ], y.*nshift=[-128 ]

flt2SD:converted x=[-1 ] to y=[-1 ], y.*nshift=[-128 ]

flt2SD:converted x=[2 ] to y=[2 ], y.*nshift=[256 ]

flt2SD:converted x=[2 ] to y=[2 ], y.*nshift=[256 ]

flt2SD:converted x=[-2 ] to y=[-2 ], y.*nshift=[-256 ]

flt2SD:converted x=[-2 ] to y=[-2 ], y.*nshift=[-256 ]

flt2SD:converted x=[1.5 ] to y=[1.5 ], y.*nshift=[192 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]

flt2SD:converted x=[0.00390625 ] to y=[0.0078125 ], y.*nshift=[1 ]

flt2SD:converted x=[0.00390625 ] to y=[0.0078125 ], y.*nshift=[1 ]

flt2SD:converted x=[0.003125 ] to y=[-0 ], y.*nshift=[0 ]

flt2SD:converted x=[0.003125 ] to y=[-0 ], y.*nshift=[0 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]

flt2SD:converted x=[-0.00390625 ] to y=[-0.0078125 ], y.*nshift=[-1 ]

flt2SD:converted x=[-0.00390625 ] to y=[-0.0078125 ], y.*nshift=[-1 ]

flt2SD:converted x=[-0.003125 ] to y=[0 ], y.*nshift=[0 ]

flt2SD:converted x=[-0.003125 ] to y=[0 ], y.*nshift=[0 ]

flt2SD:converted x=[0.1111 ] to y=[0.109375 ], y.*nshift=[14 ]

flt2SD:converted x=[-0.1111 ] to y=[-0.109375 ], y.*nshift=[-14 ]

flt2SD:converted x=[0.1111 ] to y=[0.111084 ], y.*nshift=[3640 ]

flt2SD:converted x=[-0.1111 ] to y=[-0.111084 ], y.*nshift=[-3640 ]

flt2SD:converted x=[0.1111 ] to y=[0.1111 ], y.*nshift=[125087466389504 ]

flt2SD:converted x=[0.1111 ] to y=[0.1111 ], y.*nshift=[125087479650216 ]

flt2SD:converted x=[4.1111 ] to y=[4.125 ], y.*nshift=[528 ]

flt2SD:converted x=[-4.1111 ] to y=[-4.125 ], y.*nshift=[-528 ]

flt2SD:converted x=[4.1111 ] to y=[4.11133 ], y.*nshift=[134720 ]

flt2SD:converted x=[-4.1111 ] to y=[-4.11133 ], y.*nshift=[-134720 ]

flt2SD:converted x=[4.1111 ] to y=[4.1111 ], y.*nshift=[4628687060205568 ]

flt2SD:converted x=[4.1111 ] to y=[4.1111 ], y.*nshift=[4628687107020712 ]

flt2SD:converted x=[0.5 -0.5 ] to y=[0.5 -0.5 ], y.*nshift=[64 -64 ]

flt2SD:converted x=[0.5 0.375 -0.5 -0.375 ] to y=[0.5 0.375 -0.5 -0.375 ], y.*nshift=[64 48 -64 -48 ]

flt2SD:converted x=[1.02 1 -1 -1.02 ] to y=[1.01562 1 -1 -1.01562 ], y.*nshift=[130 128 -128 -130 ]

flt2SD:converted x=[0.46875 0.15625 0.3125 0.1875 -0.21875 -0.375 0.1875 0.234375 -0.3125 0.375 0.46875 0.242188 0.375 0.3125 0.375 -0.1875 ] to y=[0.46875 0.15625 0.3125 0.1875 -0.21875 -0.375 0.1875 0.234375 -0.3125 0.375 0.46875 0.242188 0.375 0.3125 0.375 -0.1875 ], y.*nshift=[60 20 40 24 -28 -48 24 30 -40 48 60 31 48 40 48 -24 ]

flt2SD:converted x=[-0.851562 -0.84375 -0.835938 -0.828125 -0.820312 -0.8125 -0.804688 ] to y=[-0.875 -0.875 -0.875 -0.875 -0.875 -0.75 -0.75 ], y.*nshift=[-112 -112 -112 -112 -112 -96 -96 ]

flt2SD:converted x=[-0.703125 -0.695312 -0.6875 -0.679688 -0.671875 -0.664062 -0.65625 -0.648438 -0.640625 -0.632812 -0.625 ] to y=[-0.75 -0.75 -0.75 -0.625 -0.625 -0.625 -0.625 -0.625 -0.625 -0.625 -0.625 ], y.*nshift=[-96 -96 -96 -80 -80 -80 -80 -80 -80 -80 -80 ]

flt2SD:converted x=[-0.351562 -0.34375 -0.335938 -0.328125 -0.320312 -0.3125 ] to y=[-0.375 -0.375 -0.3125 -0.3125 -0.3125 -0.3125 ], y.*nshift=[-48 -48 -40 -40 -40 -40 ]

flt2SD:converted x=[0.3125 0.320312 0.328125 0.335938 0.34375 0.351562 ] to y=[0.3125 0.3125 0.3125 0.3125 0.375 0.375 ], y.*nshift=[40 40 40 40 48 48 ]

flt2SD:converted x=[0.625 0.632812 0.640625 0.648438 0.65625 0.664062 0.671875 0.679688 0.6875 0.695312 0.703125 ] to y=[0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.625 0.75 0.75 0.75 ], y.*nshift=[80 80 80 80 80 80 80 80 96 96 96 ]

flt2SD:converted x=[0.804688 0.8125 0.820312 0.828125 0.835938 0.84375 0.851562 ] to y=[0.75 0.75 0.875 0.875 0.875 0.875 0.875 ], y.*nshift=[96 96 112 112 112 112 112 ]

flt2SD:converted x=[0 ] to y=[0 ], y.*nshift=[0 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0 ] to y=[0 ], y.*nshift=[0 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[0 ], yl.*nshift=[0 ]

flt2SD:converted x=[1 ] to y=[1 ], y.*nshift=[128 ]
yu=[1 ], yu.*nshift=[128 ]
yl=[1 ], yl.*nshift=[128 ]

flt2SD:converted x=[1 ] to y=[1 ], y.*nshift=[128 ]
yu=[1 ], yu.*nshift=[128 ]
yl=[1 ], yl.*nshift=[128 ]

flt2SD:converted x=[-1 ] to y=[-1 ], y.*nshift=[-128 ]
yu=[-1 ], yu.*nshift=[-128 ]
yl=[-1 ], yl.*nshift=[-128 ]

flt2SD:converted x=[-1 ] to y=[-1 ], y.*nshift=[-128 ]
yu=[-1 ], yu.*nshift=[-128 ]
yl=[-1 ], yl.*nshift=[-128 ]

flt2SD:converted x=[2 ] to y=[2 ], y.*nshift=[256 ]
yu=[2 ], yu.*nshift=[256 ]
yl=[2 ], yl.*nshift=[256 ]

flt2SD:converted x=[2 ] to y=[2 ], y.*nshift=[256 ]
yu=[2 ], yu.*nshift=[256 ]
yl=[2 ], yl.*nshift=[256 ]

flt2SD:converted x=[-2 ] to y=[-2 ], y.*nshift=[-256 ]
yu=[-2 ], yu.*nshift=[-256 ]
yl=[-2 ], yl.*nshift=[-256 ]

flt2SD:converted x=[-2 ] to y=[-2 ], y.*nshift=[-256 ]
yu=[-2 ], yu.*nshift=[-256 ]
yl=[-2 ], yl.*nshift=[-256 ]

flt2SD:converted x=[1.5 ] to y=[1.5 ], y.*nshift=[192 ]
yu=[1.5 ], yu.*nshift=[192 ]
yl=[1.5 ], yl.*nshift=[192 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]
yu=[0.5 ], yu.*nshift=[64 ]
yl=[0.5 ], yl.*nshift=[64 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]
yu=[0.5 ], yu.*nshift=[64 ]
yl=[0.5 ], yl.*nshift=[64 ]

flt2SD:converted x=[0.5 ] to y=[0.5 ], y.*nshift=[64 ]
yu=[0.5 ], yu.*nshift=[64 ]
yl=[0.5 ], yl.*nshift=[64 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]
yu=[0.25 ], yu.*nshift=[32 ]
yl=[0.25 ], yl.*nshift=[32 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]
yu=[0.25 ], yu.*nshift=[32 ]
yl=[0.25 ], yl.*nshift=[32 ]

flt2SD:converted x=[0.25 ] to y=[0.25 ], y.*nshift=[32 ]
yu=[0.25 ], yu.*nshift=[32 ]
yl=[0.25 ], yl.*nshift=[32 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[0.0078125 ], yl.*nshift=[1 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[0.0078125 ], yl.*nshift=[1 ]

flt2SD:converted x=[0.00390625 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.00390625 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.003125 ] to y=[-0 ], y.*nshift=[0 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.003125 ] to y=[-0 ], y.*nshift=[0 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.0046875 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.0046875 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[-0 ], yl.*nshift=[0 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[0.0078125 ], yl.*nshift=[1 ]

flt2SD:converted x=[0.0078125 ] to y=[0.0078125 ], y.*nshift=[1 ]
yu=[0.0078125 ], yu.*nshift=[1 ]
yl=[0.0078125 ], yl.*nshift=[1 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]
yu=[-0.5 ], yu.*nshift=[-64 ]
yl=[-0.5 ], yl.*nshift=[-64 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]
yu=[-0.5 ], yu.*nshift=[-64 ]
yl=[-0.5 ], yl.*nshift=[-64 ]

flt2SD:converted x=[-0.5 ] to y=[-0.5 ], y.*nshift=[-64 ]
yu=[-0.5 ], yu.*nshift=[-64 ]
yl=[-0.5 ], yl.*nshift=[-64 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]
yu=[-0.25 ], yu.*nshift=[-32 ]
yl=[-0.25 ], yl.*nshift=[-32 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]
yu=[-0.25 ], yu.*nshift=[-32 ]
yl=[-0.25 ], yl.*nshift=[-32 ]

flt2SD:converted x=[-0.25 ] to y=[-0.25 ], y.*nshift=[-32 ]
yu=[-0.25 ], yu.*nshift=[-32 ]
yl=[-0.25 ], yl.*nshift=[-32 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[-0.0078125 ], yu.*nshift=[-1 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[-0.0078125 ], yu.*nshift=[-1 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.00390625 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.00390625 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.003125 ] to y=[0 ], y.*nshift=[0 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.003125 ] to y=[0 ], y.*nshift=[0 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.0046875 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.0046875 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[0 ], yu.*nshift=[0 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[-0.0078125 ], yu.*nshift=[-1 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[-0.0078125 ] to y=[-0.0078125 ], y.*nshift=[-1 ]
yu=[-0.0078125 ], yu.*nshift=[-1 ]
yl=[-0.0078125 ], yl.*nshift=[-1 ]

flt2SD:converted x=[0.1111 ] to y=[0.109375 ], y.*nshift=[14 ]
yu=[0.117188 ], yu.*nshift=[15 ]
yl=[0.109375 ], yl.*nshift=[14 ]

flt2SD:converted x=[-0.1111 ] to y=[-0.109375 ], y.*nshift=[-14 ]
yu=[-0.109375 ], yu.*nshift=[-14 ]
yl=[-0.117188 ], yl.*nshift=[-15 ]

flt2SD:converted x=[0.1111 ] to y=[0.111084 ], y.*nshift=[3640 ]
yu=[0.111206 ], yu.*nshift=[3644 ]
yl=[0.111084 ], yl.*nshift=[3640 ]

flt2SD:converted x=[-0.1111 ] to y=[-0.111084 ], y.*nshift=[-3640 ]
yu=[-0.111084 ], yu.*nshift=[-3640 ]
yl=[-0.111206 ], yl.*nshift=[-3644 ]

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

