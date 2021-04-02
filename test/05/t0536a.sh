#!/bin/sh

prog=directFIRsymmetric_sdp_bandpass_test.m

depends="directFIRsymmetric_sdp_bandpass_test.m test_common.m \
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
hM15 = [  -0.0050412867,  -0.0005569992,  -0.0032053233,  -0.0114547197, ... 
           0.0058122506,   0.0158992135,  -0.0011033475,   0.0274394133, ... 
           0.0506894643,  -0.0189930478,  -0.0279721234,   0.0181840221, ... 
          -0.1414790755,  -0.2451630093,   0.1220942248,   0.4338781211 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM16.ok << 'EOF'
hM16 = [  -0.0008627531,  -0.0054182251,  -0.0011761085,  -0.0050203551, ... 
          -0.0125222283,   0.0062076810,   0.0143379076,  -0.0012103116, ... 
           0.0302848760,   0.0508389915,  -0.0191866151,  -0.0246602289, ... 
           0.0184856307,  -0.1446318416,  -0.2439355208,   0.1213944419, ... 
           0.4291493370 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM16.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM15.ok directFIRsymmetric_sdp_bandpass_test_hM15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM15.ok"; fail; fi

diff -Bb test_hM16.ok directFIRsymmetric_sdp_bandpass_test_hM16_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM16.ok"; fail; fi

#
# this much worked
#
pass

