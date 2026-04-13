#!/bin/sh

prog=sedumi_minphase_test.m
depends="test/sedumi_minphase_test.m sedumi_minphase_test_data.mat \
test_common.m print_polynomial.m qroots.oct"

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
cat > test_h_coef.ok << 'EOF'
h = [  -0.0250479892,  -0.0615620234,  -0.1194983522,  -0.1796054715, ... 
       -0.2258126465,  -0.2343969009,  -0.1961028321,  -0.1170443456, ... 
       -0.0205499260,   0.0605575487,   0.1002001946,   0.0890447352, ... 
        0.0398309652,  -0.0191381134,  -0.0589839656,  -0.0628617022, ... 
       -0.0342269117,   0.0076402405,   0.0391388207,   0.0450002759, ... 
        0.0257750790,  -0.0045212611,  -0.0278451219,  -0.0322549753, ... 
       -0.0181631691,   0.0037798178,   0.0201556466,   0.0224962727, ... 
        0.0118196223,  -0.0036488659,  -0.0143696919,  -0.0148598955, ... 
       -0.0068025350,   0.0035874741,   0.0100000033,   0.0091326690, ... 
        0.0033536332,  -0.0032604424,  -0.0065711037,  -0.0050449269, ... 
       -0.0013071190,   0.0026806631,   0.0040023808,   0.0023371542, ... 
        0.0009248906,  -0.0031553944,  -0.0035475787,   0.0016761943 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test_h_coef.ok sedumi_minphase_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

