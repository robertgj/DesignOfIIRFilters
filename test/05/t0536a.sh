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
hM15 = [  -0.0051580667,  -0.0009795987,  -0.0039581331,  -0.0125007385, ... 
           0.0044611719,   0.0145602753,  -0.0018351032,   0.0275108972, ... 
           0.0515054695,  -0.0173702551,  -0.0260249114,   0.0194463102, ... 
          -0.1412891235,  -0.2459630405,   0.1201954862,   0.4313854854 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM30.ok << 'EOF'
hM30 = [   0.0025116878,   0.0007103166,  -0.0023326986,  -0.0008116746, ... 
          -0.0006029669,  -0.0043668911,  -0.0022405458,   0.0070784579, ... 
           0.0068238859,  -0.0019083970,  -0.0002714783,   0.0021952346, ... 
          -0.0117834661,  -0.0164785113,   0.0072138071,   0.0193223067, ... 
           0.0029368977,   0.0043899825,   0.0189844916,  -0.0125788102, ... 
          -0.0522748348,  -0.0163017849,   0.0336444042,   0.0105094810, ... 
           0.0096652893,   0.0858975136,   0.0454094157,  -0.1668162920, ... 
          -0.2062363098,   0.0891589876,   0.3002667527 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM30.ok"; fail; fi

cat > test_hM80.ok << 'EOF'
hM80 = [  -0.0000639869,   0.0000221685,   0.0000757608,   0.0000592825, ... 
          -0.0001046901,  -0.0001203408,   0.0000395214,   0.0000590722, ... 
           0.0000446941,   0.0001864170,   0.0000021759,  -0.0004701338, ... 
          -0.0002148945,   0.0005010251,   0.0003376415,  -0.0001742988, ... 
          -0.0000001835,  -0.0001939294,  -0.0007952585,   0.0001420286, ... 
           0.0014290541,   0.0003001962,  -0.0011579109,  -0.0003890060, ... 
           0.0000116615,  -0.0005933595,   0.0009803635,   0.0022385214, ... 
          -0.0008235797,  -0.0029527331,  -0.0000882050,   0.0014832369, ... 
           0.0000592147,   0.0013933847,   0.0019472145,  -0.0032015225, ... 
          -0.0044622690,   0.0023578833,   0.0043458596,  -0.0003393307, ... 
          -0.0001746707,   0.0004461724,  -0.0053681461,  -0.0037493640, ... 
           0.0074877864,   0.0067065507,  -0.0044104101,  -0.0041298555, ... 
           0.0000345275,  -0.0046388001,  -0.0000958087,   0.0132419683, ... 
           0.0050100159,  -0.0137114044,  -0.0076436215,   0.0052413328, ... 
           0.0002853817,   0.0035621330,   0.0152978962,  -0.0033423920, ... 
          -0.0263698275,  -0.0043365486,   0.0206130024,   0.0059378797, ... 
          -0.0002801964,   0.0101552087,  -0.0169621257,  -0.0372398491, ... 
           0.0150884777,   0.0501064780,   0.0001893760,  -0.0260942653, ... 
          -0.0001325078,  -0.0299085835,  -0.0433060476,   0.0818564271, ... 
           0.1278159868,  -0.0883935332,  -0.2137441853,   0.0380415029, ... 
           0.2510227339 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM80.ok"; fail; fi

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

diff -Bb test_hM80.ok directFIRsymmetric_sdp_bandpass_test_hM80_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM80.ok"; fail; fi

#
# this much worked
#
pass

