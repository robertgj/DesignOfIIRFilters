#!/bin/sh

prog=saramakiFBvNewton_test.m
depends="saramakiFBvNewton_test.m test_common.m saramakiFBv.m \
saramakiFBvNewton.m local_max.m print_polynomial.m qroots.m qzsolve.oct"

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
n =  6
m =  9
fp =  0.20000
fs =  0.35000
dBap =  0.10000
n= 6,m=7,max_dBap=0.000593,min_dBap=-0.099421,max_dBas=-104.43
n= 6,m=8,max_dBap=0.000307,min_dBap=-0.099446,max_dBas=-115.82
n= 6,m=9,max_dBap=0.000265,min_dBap=-0.099418,max_dBas=-127.29
n= 6,m=10,max_dBap=0.000385,min_dBap=-0.099467,max_dBas=-138.85
n= 7,m=8,max_dBap=0.000472,min_dBap=-0.099418,max_dBas=-124.81
n= 7,m=9,max_dBap=0.000587,min_dBap=-0.099418,max_dBas=-136.20
n= 7,m=10,max_dBap=0.000535,min_dBap=-0.099419,max_dBas=-147.67
n= 7,m=11,max_dBap=0.004487,min_dBap=-0.099502,max_dBas=-159.22
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
