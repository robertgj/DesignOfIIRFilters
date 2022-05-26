#!/bin/sh

prog=directFIRsymmetric_sdp_bandpass_test.m

depends="test/directFIRsymmetric_sdp_bandpass_test.m test_common.m \
print_polynomial.m directFIRsymmetricA.m directFIRsymmetric_sdp_basis.m \
directFIRsymmetricEsqPW.m local_max.m"

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
cat > test_hM15.ok << 'EOF'
hM15 = [  -0.0050212398,  -0.0004914857,  -0.0030950469,  -0.0113105471, ... 
           0.0059868031,   0.0160489627,  -0.0010735428,   0.0273232937, ... 
           0.0504467150,  -0.0193569744,  -0.0283613440,   0.0179456384, ... 
          -0.1414980697,  -0.2449774887,   0.1224896438,   0.4343808766 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM16.ok << 'EOF'
hM16 = [  -0.0008351347,  -0.0054454581,  -0.0011921862,  -0.0049780306, ... 
          -0.0125508413,   0.0061337599,   0.0144382331,  -0.0011940030, ... 
           0.0301591093,   0.0509451235,  -0.0190933522,  -0.0248451935, ... 
           0.0185013401,  -0.1444429679,  -0.2441145682,   0.1213269399, ... 
           0.4293744717 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM16.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM15.ok directFIRsymmetric_sdp_bandpass_test_hM15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM15.ok"; fail; fi

diff -Bb test_hM16.ok directFIRsymmetric_sdp_bandpass_test_hM16_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM16.ok"; fail; fi

#
# this much worked
#
pass

