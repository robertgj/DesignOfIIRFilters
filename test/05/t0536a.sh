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
hM15 = [  -0.0051579976,  -0.0009795962,  -0.0039580719,  -0.0125007096, ... 
           0.0044611094,   0.0145602303,  -0.0018350437,   0.0275109709, ... 
           0.0515054409,  -0.0173703437,  -0.0260249591,   0.0194463498, ... 
          -0.1412890767,  -0.2459630618,   0.1201954411,   0.4313855272 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM30.ok << 'EOF'
hM30 = [   0.0025093069,   0.0007114051,  -0.0023419844,  -0.0008094684, ... 
          -0.0006182634,  -0.0043654443,  -0.0022541585,   0.0070774093, ... 
           0.0068199123,  -0.0019129293,  -0.0002664733,   0.0021898135, ... 
          -0.0117761589,  -0.0164787444,   0.0072201517,   0.0193335088, ... 
           0.0029430792,   0.0044090650,   0.0189918520,  -0.0125646661, ... 
          -0.0522673033,  -0.0163007259,   0.0336534593,   0.0105009623, ... 
           0.0096751290,   0.0858878761,   0.0454128109,  -0.1668259712, ... 
          -0.2062454817,   0.0891478804,   0.3002502340 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM30.ok"; fail; fi

cat > test_hM80.ok << 'EOF'
hM80 = [  -0.0000639869,   0.0000221684,   0.0000757608,   0.0000592825, ... 
          -0.0001046901,  -0.0001203408,   0.0000395214,   0.0000590722, ... 
           0.0000446941,   0.0001864170,   0.0000021759,  -0.0004701338, ... 
          -0.0002148945,   0.0005010251,   0.0003376415,  -0.0001742988, ... 
          -0.0000001835,  -0.0001939294,  -0.0007952585,   0.0001420287, ... 
           0.0014290541,   0.0003001962,  -0.0011579109,  -0.0003890060, ... 
           0.0000116615,  -0.0005933595,   0.0009803635,   0.0022385214, ... 
          -0.0008235797,  -0.0029527331,  -0.0000882050,   0.0014832369, ... 
           0.0000592147,   0.0013933848,   0.0019472145,  -0.0032015225, ... 
          -0.0044622690,   0.0023578833,   0.0043458597,  -0.0003393307, ... 
          -0.0001746706,   0.0004461723,  -0.0053681461,  -0.0037493640, ... 
           0.0074877864,   0.0067065507,  -0.0044104101,  -0.0041298556, ... 
           0.0000345275,  -0.0046388002,  -0.0000958087,   0.0132419684, ... 
           0.0050100159,  -0.0137114043,  -0.0076436215,   0.0052413327, ... 
           0.0002853817,   0.0035621330,   0.0152978962,  -0.0033423920, ... 
          -0.0263698275,  -0.0043365486,   0.0206130023,   0.0059378797, ... 
          -0.0002801964,   0.0101552087,  -0.0169621258,  -0.0372398491, ... 
           0.0150884776,   0.0501064779,   0.0001893760,  -0.0260942652, ... 
          -0.0001325078,  -0.0299085836,  -0.0433060477,   0.0818564272, ... 
           0.1278159869,  -0.0883935331,  -0.2137441853,   0.0380415029, ... 
           0.2510227338 ]';
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

