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
x = [   0.0055312083, ...
       -2.5172947901,  -1.3160771736, ...
       -0.9079549734,  -0.2702665552, ...
        1.3053633956,   1.2801339760,   1.2456925229,   1.3543680148, ... 
        1.3403320932,   1.3017549399,   1.1940407510,   1.0576998890, ... 
        0.8556848206,   0.6295806050,   0.5427391704, ...
        2.8130835406,   2.4936279734,   2.1815983114,   0.2206287582, ... 
        0.6636852829,   1.1146346726,   1.8756695277,   1.6003203081, ... 
        1.5609084989,   1.0945345539,   0.3907008473 ]';
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

