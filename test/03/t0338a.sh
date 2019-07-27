#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="tarczynski_deczky1_test.m \
test_common.m print_polynomial.m WISEJ_ND.m tf2Abcd.m \
print_pole_zero.m tf2x.m zp2x.m qroots.m qzsolve.oct"

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
cat > test.ok.N << 'EOF'
N = [   0.0095377735,   0.0109597902,  -0.0258496926,   0.0045841729, ... 
        0.0146569794,   0.0073699004,  -0.0548486454,   0.0103623683, ... 
        0.2235293748,   0.4134052838,   0.3932894104,   0.2135738398, ... 
        0.0572876661 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N"; fail; fi

cat > test.ok.D << 'EOF'
D = [   1.0000000000,  -0.5053476243,   1.2073247351,  -0.7848158627, ... 
        0.5547276151,  -0.2687559527,   0.0798488862 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D"; fail; fi
cat > test.ok.x << 'EOF'
Ux=2,Vx=0,Mx=10,Qx=6,Rx=1
x = [   0.0095377735, ...
       -2.3534528836,  -0.7656995132, ...
        0.8134550416,   0.8901331226,   0.9700178111,   1.5552659293, ... 
        1.6712916315, ...
        2.5091243129,   2.1065386797,   1.9141468740,   1.0029585790, ... 
        0.3215244138, ...
        0.4636962702,   0.6933056003,   0.8789741853, ...
        0.5711991836,   1.4853187193,   1.7963769022 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.x"; fail; fi
#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.N tarczynski_deczky1_test_N_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N"; fail; fi

diff -Bb test.ok.D tarczynski_deczky1_test_D_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D"; fail; fi

diff -Bb test.ok.x tarczynski_deczky1_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.x"; fail; fi

#
# this much worked
#
pass
