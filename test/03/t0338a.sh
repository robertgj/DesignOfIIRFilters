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
x = [   0.0089246099, ...
       -1.6983334070,  -1.4198229400, ...
        1.6379644123,   1.5738900106,   0.9774087047,   0.9048931379, ... 
        0.8170264595, ...
        0.3421146572,   1.0333529676,   1.9056293108,   2.0813761609, ... 
        2.4705991917, ...
        0.9322535650,   0.6589433156,   0.4371466775, ...
        1.7291383648,   1.4944539264,   0.5877826891 ]';
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
