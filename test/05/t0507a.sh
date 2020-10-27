#!/bin/sh

prog=sedumi_minphase_test.m
depends="sedumi_minphase_test.m sedumi_minphase_test_data.mat \
test_common.m print_polynomial.m"

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
h = [  -0.0016763229,   0.0035456021,   0.0031623258,  -0.0009271359, ... 
       -0.0023413861,  -0.0040055183,  -0.0026817746,   0.0013141145, ... 
        0.0050487718,   0.0065738230,   0.0032589222,  -0.0033629580, ... 
       -0.0091396177,  -0.0100025669,  -0.0035803114,   0.0068163468, ... 
        0.0148687675,   0.0143696418,   0.0036351510,  -0.0118380581, ... 
       -0.0225065771,  -0.0201518417,  -0.0037590749,   0.0181868685, ... 
        0.0322669528,   0.0278371918,   0.0044929208,  -0.0258052959, ... 
       -0.0450152023,  -0.0391272725,  -0.0076037994,   0.0342659908, ... 
        0.0628828671,   0.0589715928,   0.0190940268,  -0.0398824752, ... 
       -0.0890799791,  -0.1001961929,  -0.0605128226,   0.0206150474, ... 
        0.1171079933,   0.1961352536,   0.2343941401,   0.2257864062, ... 
        0.1795593086,   0.1194678738,   0.0615345927,   0.0250488857 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test_h_coef.ok sedumi_minphase_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

