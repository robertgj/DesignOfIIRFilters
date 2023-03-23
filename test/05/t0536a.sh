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
hM15 = [  -0.0051579522,  -0.0009795946,  -0.0039580318,  -0.0125006906, ... 
           0.0044610682,   0.0145602006,  -0.0018350046,   0.0275110194, ... 
           0.0515054222,  -0.0173704017,  -0.0260249902,   0.0194463757, ... 
          -0.1412890461,  -0.2459630757,   0.1201954113,   0.4313855543 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM30.ok << 'EOF'
hM30 = [   0.0025092982,   0.0007114071,  -0.0023419869,  -0.0008094665, ... 
          -0.0006182691,  -0.0043654418,  -0.0022541597,   0.0070774071, ... 
           0.0068199157,  -0.0019129318,  -0.0002664843,   0.0021898107, ... 
          -0.0117761441,  -0.0164787362,   0.0072201480,   0.0193335145, ... 
           0.0029430873,   0.0044090531,   0.0189918389,  -0.0125646504, ... 
          -0.0522672821,  -0.0163007263,   0.0336534534,   0.0105009645, ... 
           0.0096751328,   0.0858878744,   0.0454128240,  -0.1668259776, ... 
          -0.2062454909,   0.0891478784,   0.3002502641 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM30.ok"; fail; fi

cat > test_hM80.ok << 'EOF'
hM80 = [  -0.0000639868,   0.0000221684,   0.0000757608,   0.0000592824, ... 
          -0.0001046901,  -0.0001203408,   0.0000395215,   0.0000590722, ... 
           0.0000446941,   0.0001864170,   0.0000021759,  -0.0004701338, ... 
          -0.0002148945,   0.0005010252,   0.0003376415,  -0.0001742989, ... 
          -0.0000001835,  -0.0001939294,  -0.0007952585,   0.0001420287, ... 
           0.0014290542,   0.0003001962,  -0.0011579110,  -0.0003890061, ... 
           0.0000116615,  -0.0005933594,   0.0009803636,   0.0022385215, ... 
          -0.0008235797,  -0.0029527332,  -0.0000882050,   0.0014832370, ... 
           0.0000592147,   0.0013933848,   0.0019472145,  -0.0032015226, ... 
          -0.0044622691,   0.0023578834,   0.0043458598,  -0.0003393307, ... 
          -0.0001746707,   0.0004461723,  -0.0053681461,  -0.0037493640, ... 
           0.0074877865,   0.0067065508,  -0.0044104101,  -0.0041298556, ... 
           0.0000345275,  -0.0046388001,  -0.0000958087,   0.0132419684, ... 
           0.0050100159,  -0.0137114044,  -0.0076436215,   0.0052413328, ... 
           0.0002853817,   0.0035621331,   0.0152978961,  -0.0033423920, ... 
          -0.0263698275,  -0.0043365485,   0.0206130023,   0.0059378797, ... 
          -0.0002801964,   0.0101552087,  -0.0169621258,  -0.0372398490, ... 
           0.0150884777,   0.0501064779,   0.0001893760,  -0.0260942651, ... 
          -0.0001325078,  -0.0299085837,  -0.0433060477,   0.0818564273, ... 
           0.1278159870,  -0.0883935333,  -0.2137441855,   0.0380415029, ... 
           0.2510227334 ]';
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

