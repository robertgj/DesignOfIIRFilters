#!/bin/sh

prog=saramakiFAvLogNewton_test.m
depends="saramakiFAvLogNewton_test.m test_common.m saramakiFAvLogNewton.m \
local_max.m qroots.m qzsolve.oct"

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
n =  11
m =  6
fp =  0.10000
fs =  0.12500
dBap =  0.0020000
dBas =  75
z =

   0.70283 + 0.71135i
   0.70283 - 0.71135i
   0.66136 + 0.75007i
   0.66136 - 0.75007i
   0.51018 + 0.86007i
   0.51018 - 0.86007i

p =

   0.77319 + 0.59917i
   0.77319 - 0.59917i
   0.74845 + 0.55029i
   0.74845 - 0.55029i
   0.72892 + 0.46703i
   0.72892 - 0.46703i
   0.71739 + 0.34124i
   0.71739 - 0.34124i
   0.71543 + 0.17976i
   0.71543 - 0.17976i
   0.71643 + 0.00000i

K =  0.00070079
iter =  41
n=11,m=6,max_dBap=0.000000,min_dBap=-0.001713,max_dBas= 75.00
Setting dBap=0.002000
n= 3,m=3,max_dBap=0.002000,max_dBas=  0.56
n= 4,m=3,max_dBap=0.002000,max_dBas=  3.04
n= 5,m=3,max_dBap=0.002000,max_dBas=  8.72
n= 6,m=3,max_dBap=0.002000,max_dBas= 15.82
n= 7,m=3,max_dBap=0.002000,max_dBas= 23.05
n= 8,m=3,max_dBap=0.002000,max_dBas= 30.16
n= 9,m=3,max_dBap=0.002000,max_dBas= 37.12
n= 4,m=4,max_dBap=0.002000,max_dBas=  5.20
n= 5,m=4,max_dBap=0.002000,max_dBas= 13.93
n= 6,m=4,max_dBap=0.002000,max_dBas= 23.79
n= 7,m=4,max_dBap=0.002000,max_dBas= 32.95
n= 8,m=4,max_dBap=0.002000,max_dBas= 41.58
n= 9,m=4,max_dBap=0.002000,max_dBas= 49.82
n=10,m=4,max_dBap=0.002000,max_dBas= 57.77
n= 5,m=5,max_dBap=0.002000,max_dBas= 16.00
n= 6,m=5,max_dBap=0.002000,max_dBas= 25.17
n= 7,m=5,max_dBap=0.002000,max_dBas= 34.02
n= 8,m=5,max_dBap=0.002000,max_dBas= 42.48
n= 9,m=5,max_dBap=0.002000,max_dBas= 50.63
n=10,m=5,max_dBap=0.002000,max_dBas= 58.51
n=11,m=5,max_dBap=0.002000,max_dBas= 66.19
n= 6,m=6,max_dBap=0.002000,max_dBas= 28.16
n= 7,m=6,max_dBap=0.002000,max_dBas= 37.81
n= 8,m=6,max_dBap=0.002000,max_dBas= 47.89
n= 9,m=6,max_dBap=0.002000,max_dBas= 57.63
n=10,m=6,max_dBap=0.002000,max_dBas= 66.85
n=11,m=6,max_dBap=0.002000,max_dBas= 75.67
n=12,m=6,max_dBap=0.002000,max_dBas= 84.19
n= 7,m=7,max_dBap=0.002000,max_dBas= 40.41
n= 8,m=7,max_dBap=0.002000,max_dBas= 49.85
n= 9,m=7,max_dBap=0.002000,max_dBas= 59.08
n=10,m=7,max_dBap=0.002000,max_dBas= 68.03
n=11,m=7,max_dBap=0.002000,max_dBas= 76.69
n=12,m=7,max_dBap=0.002000,max_dBas= 85.10
n=13,m=7,max_dBap=0.002000,max_dBas= 93.29
n= 8,m=8,max_dBap=0.002000,max_dBas= 52.67
n= 9,m=8,max_dBap=0.002000,max_dBas= 62.22
n=10,m=8,max_dBap=0.002000,max_dBas= 71.95
n=11,m=8,max_dBap=0.002000,max_dBas= 81.93
n=12,m=8,max_dBap=0.002000,max_dBas= 91.55
n=13,m=8,max_dBap=0.002000,max_dBas=100.79
n=14,m=8,max_dBap=0.002002,max_dBas=109.73
Setting dBas= 75.00
n= 3,m=3,max_dBap=50.253853,max_dBas= 75.00
n= 4,m=3,max_dBap=41.557744,max_dBas= 75.00
n= 5,m=3,max_dBap=33.543212,max_dBas= 75.00
n= 6,m=3,max_dBap=25.931806,max_dBas= 75.00
n= 7,m=3,max_dBap=18.662169,max_dBas= 75.00
n= 8,m=3,max_dBap=11.780179,max_dBas= 75.00
n= 9,m=3,max_dBap=5.830484,max_dBas= 75.00
n= 4,m=4,max_dBap=37.943893,max_dBas= 75.00
n= 5,m=4,max_dBap=27.894831,max_dBas= 75.00
n= 6,m=4,max_dBap=17.931566,max_dBas= 75.00
n= 7,m=4,max_dBap=9.235828,max_dBas= 75.00
n= 8,m=4,max_dBap=3.038159,max_dBas= 75.00
n= 9,m=4,max_dBap=0.613963,max_dBas= 75.00
n=10,m=4,max_dBap=0.104420,max_dBas= 75.00
n= 5,m=5,max_dBap=25.752576,max_dBas= 75.00
n= 6,m=5,max_dBap=16.568491,max_dBas= 75.00
n= 7,m=5,max_dBap=8.308094,max_dBas= 75.00
n= 8,m=5,max_dBap=2.606264,max_dBas= 75.00
n= 9,m=5,max_dBap=0.515861,max_dBas= 75.00
n=10,m=5,max_dBap=0.088212,max_dBas= 75.00
n=11,m=5,max_dBap=0.015176,max_dBas= 75.00
n= 6,m=6,max_dBap=13.671126,max_dBas= 75.00
n= 7,m=6,max_dBap=5.329025,max_dBas= 75.00
n= 8,m=6,max_dBap=0.922832,max_dBas= 75.00
n= 9,m=6,max_dBap=0.107777,max_dBas= 75.00
n=10,m=6,max_dBap=0.013048,max_dBas= 75.00
n=11,m=6,max_dBap=0.001713,max_dBas= 75.00
n=12,m=6,max_dBap=0.000241,max_dBas= 75.00
n= 7,m=7,max_dBap=3.663552,max_dBas= 75.00
n= 8,m=7,max_dBap=0.609839,max_dBas= 75.00
n= 9,m=7,max_dBap=0.077440,max_dBas= 75.00
n=10,m=7,max_dBap=0.009946,max_dBas= 75.00
n=11,m=7,max_dBap=0.001355,max_dBas= 75.00
n=12,m=7,max_dBap=0.000195,max_dBas= 75.00
n=13,m=7,max_dBap=0.000030,max_dBas= 75.00
n= 8,m=8,max_dBap=0.329094,max_dBas= 75.00
n= 9,m=8,max_dBap=0.037767,max_dBas= 75.00
n=10,m=8,max_dBap=0.004040,max_dBas= 75.00
n=11,m=8,max_dBap=0.000406,max_dBas= 75.00
n=12,m=8,max_dBap=0.000044,max_dBas= 75.00
n=13,m=8,max_dBap=0.000005,max_dBas= 75.00
n=14,m=8,max_dBap=0.000001,max_dBas= 75.00
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc
octave-cli -q $prog > test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
