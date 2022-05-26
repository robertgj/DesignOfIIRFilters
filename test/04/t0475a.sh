#!/bin/sh

prog=selesnickFIRantisymmetric_flat_differentiator_test.m

depends="test/selesnickFIRantisymmetric_flat_differentiator_test.m test_common.m \
selesnickFIRantisymmetric_flat_differentiator.m local_max.m print_polynomial.m"

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
cat > test_cL10K3.ok << 'EOF'
cL10K3 = [  2.00000000000,  3.33333333333,  4.40000000000,  5.31428571429, ... 
            6.12698412698,  6.86580086580,  7.54778554779,  8.18430458430, ... 
            8.78338132456,  9.35092771006,  9.89144807721 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cL10K3.ok"; fail; fi

cat > test_hN30K00.ok << 'EOF'
hN30K00 = [  0.00000000002, -0.00000000064,  0.00000001049, -0.00000011152, ... 
             0.00000086953, -0.00000531113,  0.00002653728, -0.00011199575, ... 
             0.00041004360, -0.00133631289,  0.00399244099, -0.01139956714, ... 
             0.03351472739, -0.12174153112,  1.25219860579, -1.25219860579, ... 
             0.12174153112, -0.03351472739,  0.01139956714, -0.00399244099, ... 
             0.00133631289, -0.00041004360,  0.00011199575, -0.00002653728, ... 
             0.00000531113, -0.00000086953,  0.00000011152, -0.00000001049, ... 
             0.00000000064, -0.00000000002 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hN30K00.ok"; fail; fi

cat > test_hN30K24.ok << 'EOF'
hN30K24 = [  0.00000029830,  0.00000548645,  0.00004577059,  0.00022455882, ... 
             0.00068947173,  0.00121286130,  0.00035500862, -0.00427525577, ... 
            -0.01211188259, -0.01376205599,  0.00678964884,  0.05422227401, ... 
             0.10283743413,  0.10726738960,  0.04628950879, -0.04628950879, ... 
            -0.10726738960, -0.10283743413, -0.05422227401, -0.00678964884, ... 
             0.01376205599,  0.01211188259,  0.00427525577, -0.00035500862, ... 
            -0.00121286130, -0.00068947173, -0.00022455882, -0.00004577059, ... 
            -0.00000548645, -0.00000029830 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hN30K24.ok"; fail; fi

cat > test_hN31K01.ok << 'EOF'
hN31K01 = [  0.00000000043, -0.00000001381,  0.00000021572, -0.00000218114, ... 
             0.00001606114, -0.00009186970,  0.00042532268, -0.00164053035, ... 
             0.00539031402, -0.01537237702,  0.03873839009, -0.08804179567, ... 
             0.18586601307, -0.38602941176,  0.93750000000,  0.00000000000, ... 
            -0.93750000000,  0.38602941176, -0.18586601307,  0.08804179567, ... 
            -0.03873839009,  0.01537237702, -0.00539031402,  0.00164053035, ... 
            -0.00042532268,  0.00009186970, -0.00001606114,  0.00000218114, ... 
            -0.00000021572,  0.00000001381, -0.00000000043 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hN31K01.ok"; fail; fi

cat > test_hN31K25.ok << 'EOF'
hN31K25 = [  0.00000016118,  0.00000312924,  0.00002777204,  0.00014682611, ... 
             0.00049849972,  0.00104683042,  0.00090038404, -0.00202417374, ... 
            -0.00880764797, -0.01428827643, -0.00498487428,  0.03031075001, ... 
             0.08083594963,  0.10920301080,  0.08011965081,  0.00000000000, ... 
            -0.08011965081, -0.10920301080, -0.08083594963, -0.03031075001, ... 
             0.00498487428,  0.01428827643,  0.00880764797,  0.00202417374, ... 
            -0.00090038404, -0.00104683042, -0.00049849972, -0.00014682611, ... 
            -0.00002777204, -0.00000312924, -0.00000016118 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hN31K25.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="selesnickFIRantisymmetric_flat_differentiator_test"

diff -Bb test_cL10K3.ok $nstr"_cL10K3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cL10K3.ok"; fail; fi

diff -Bb test_hN30K00.ok $nstr"_hN30K00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hN30K00.ok"; fail; fi

diff -Bb test_hN30K24.ok $nstr"_hN30K24_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hN30K24.ok"; fail; fi

diff -Bb test_hN31K01.ok $nstr"_hN31K01_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hN31K01.ok"; fail; fi

diff -Bb test_hN31K25.ok $nstr"_hN31K25_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hN31K25.ok"; fail; fi

#
# this much worked
#
pass

