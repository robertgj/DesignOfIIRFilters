#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="tarczynski_deczky1_test.m \
test_common.m print_polynomial.m print_pole_zero.m tf2x.m WISEJ_ND.m tf2Abcd.m"
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
Ux=2,Vx=0,Mx=10,Qx=6,Rx=1
x = [   0.0095393248, ...
       -2.3530732118,  -0.7662178198, ...
        1.6712575992,   1.5552409763,   0.9700510001,   0.8901780773, ... 
        0.8134531466, ...
        0.3215459836,   1.0029563164,   1.9141390916,   2.1064191823, ... 
        2.5091066137, ...
        0.8790198707,   0.6933363297,   0.4636825808, ...
        1.7964436442,   1.4853675461,   0.5712376550 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok tarczynski_deczky1_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
