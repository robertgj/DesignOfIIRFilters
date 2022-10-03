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
hM15 = [  -0.0051534491,  -0.0009620291,  -0.0039118871,  -0.0123994269, ... 
           0.0046473851,   0.0148519899,  -0.0014319847,   0.0280084511, ... 
           0.0520437684,  -0.0168752924,  -0.0256632913,   0.0195968045, ... 
          -0.1413951061,  -0.2463137139,   0.1196712704,   0.4307979116 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM30.ok << 'EOF'
hM30 = [   0.0007934252,   0.0001873017,   0.0004246553,   0.0013399216, ... 
          -0.0010679779,  -0.0050614233,  -0.0020512359,   0.0048853259, ... 
           0.0037609398,  -0.0001108244,   0.0043031786,   0.0032403934, ... 
          -0.0125941820,  -0.0155044008,   0.0053042762,   0.0128249680, ... 
           0.0009014781,   0.0098978249,   0.0229937972,  -0.0127062693, ... 
          -0.0503109075,  -0.0153713204,   0.0265402588,   0.0030101673, ... 
           0.0119684696,   0.0917925643,   0.0465419469,  -0.1644821387, ... 
          -0.2019505283,   0.0860579494,   0.2898856919 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM30.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM15.ok directFIRsymmetric_sdp_bandpass_test_hM15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM15.ok"; fail; fi

diff -Bb test_hM30.ok directFIRsymmetric_sdp_bandpass_test_hM30_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM30.ok"; fail; fi

#
# this much worked
#
pass

