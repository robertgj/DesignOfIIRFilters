#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="test/tarczynski_deczky1_test.m \
test_common.m delayz.m print_polynomial.m WISEJ.m tf2Abcd.m \
print_pole_zero.m tf2x.m zp2x.m qroots.oct"

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
cat > test.ok.N0 << 'EOF'
N0 = [   0.0044217179,  -0.0080775421,  -0.0080233018,   0.0108649558, ... 
         0.0113779459,  -0.0350035925,  -0.0180699290,   0.2024318587, ... 
         0.5443290455,   0.7186003675,   0.5759020416,   0.2772544218, ... 
         0.0653644477 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,   0.0904428032,   1.1843915889,  -0.1475282824, ... 
         0.2712729997,  -0.0614933098,   0.0048547988 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.x0 << 'EOF'
Ux0=0,Vx0=0,Mx0=12,Qx0=6,Rx0=1
x0 = [   0.0044217179, ...
         0.9213646730,   0.9333371011,   0.9651754587,   0.9929112235, ... 
         1.9481787055,   2.3947474188, ...
         2.9018230816,   2.4917675599,   2.1383740680,   1.9250702215, ... 
         0.9748303581,   0.2482984738, ...
         0.1318271421,   0.5502325464,   0.9605821326, ...
         0.5245892454,   1.6197273435,   1.7090790906 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.x0"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=tarczynski_deczky1_test

diff -Bb test.ok.N0 $nstr"_N0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

diff -Bb test.ok.D0 $nstr"_D0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.x0 $nstr"_x0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.x0"; fail; fi

#
# this much worked
#
pass
