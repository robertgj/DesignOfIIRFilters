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
h = [  -0.0250479840,  -0.0615642332,  -0.1195002328,  -0.1796085416, ... 
       -0.2258146016,  -0.2343970411,  -0.1961004812,  -0.1170400163, ... 
       -0.0205454851,   0.0605606103,   0.1002005206,   0.0890424103, ... 
        0.0398274496,  -0.0191411512,  -0.0589848573,  -0.0628602855, ... 
       -0.0342242180,   0.0076427401,   0.0391396120,   0.0449992355, ... 
        0.0257729943,  -0.0045231695,  -0.0278456277,  -0.0322541250, ... 
       -0.0181615648,   0.0037811716,   0.0201558676,   0.0224955639, ... 
        0.0118184189,  -0.0036497386,  -0.0143696965,  -0.0148593196, ... 
       -0.0068016536,   0.0035879503,   0.0099998785,   0.0091321971, ... 
        0.0033530031,  -0.0032605678,  -0.0065708948,  -0.0050445667, ... 
       -0.0013068212,   0.0026804910,   0.0040024648,   0.0023368126, ... 
        0.0009245749,  -0.0031548466,  -0.0035476857,   0.0016761650 ]';
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

