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
hM15 = [  -0.0052289880,  -0.0012452771,  -0.0044344014,  -0.0131273573, ... 
           0.0037447105,   0.0140074478,  -0.0018182699,   0.0282344255, ... 
           0.0528407161,  -0.0155390268,  -0.0241839805,   0.0205024967, ... 
          -0.1413815017,  -0.2471625176,   0.1179626489,   0.4286598872 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM16.ok << 'EOF'
hM16 = [  -0.0011808429,  -0.0050467623,  -0.0009846122,  -0.0055569681, ... 
          -0.0121542937,   0.0070519398,   0.0129996158,  -0.0014253054, ... 
           0.0318353468,   0.0495158691,  -0.0202162418,  -0.0222090135, ... 
           0.0183471717,  -0.1469524786,  -0.2417363615,   0.1221227689, ... 
           0.4261804380 ]';
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

