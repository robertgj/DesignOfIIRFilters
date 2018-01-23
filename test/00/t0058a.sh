#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="tarczynski_ex2_standalone_test.m test_common.m \
tf2x.m print_polynomial.m print_pole_zero.m"

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
Ux=2,Vx=2,Mx=22,Qx=0,Rx=2
x = [   0.0055318501, ...
       -2.5170628267,  -1.3160752171, ...
       -0.9079560306,  -0.2702693669, ...
        1.3053646150,   1.2801395738,   1.2456947672,   1.3543532252, ... 
        1.3403287270,   1.3017511081,   1.1940391431,   1.0576999798, ... 
        0.8556865803,   0.6295823844,   0.5427361878, ...
        2.8130739332,   2.4936224647,   2.1815962607,   0.2206288358, ... 
        0.6636910430,   1.1146343826,   1.8756693941,   1.6003195241, ... 
        1.5609093563,   1.0945324853,   0.3906957551 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok tarczynski_ex2_standalone_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

