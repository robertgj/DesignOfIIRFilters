#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_alternate_test.m

depends="directFIRnonsymmetric_kyp_lowpass_alternate_test.m test_common.m \
directFIRnonsymmetricEsqPW.m print_polynomial.m"

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
cat > test_h1_coef.ok << 'EOF'
h1 = [ -0.0102419248,  0.0047969808,  0.0219730711,  0.0284875370, ... 
        0.0061036595, -0.0371278380, -0.0583180703, -0.0083135632, ... 
        0.1198359608,  0.2675512611,  0.3433129293,  0.2919754179, ... 
        0.1425119062, -0.0111461865, -0.0825218387, -0.0561355178, ... 
        0.0115735726,  0.0495435698,  0.0319654651, -0.0111795017, ... 
       -0.0338893482, -0.0195790001,  0.0100940934,  0.0237484960, ... 
        0.0119500096, -0.0086465922, -0.0167373848, -0.0073513316, ... 
        0.0075019201,  0.0142428526,  0.0112348161 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h1_coef.m "; fail; fi

cat > test_h2_coef.ok << 'EOF'
h2 = [ -0.0090173094,  0.0082328255,  0.0260768390,  0.0325925310, ... 
        0.0089356822, -0.0359418366, -0.0580526173, -0.0080355101, ... 
        0.1203721572,  0.2678695205,  0.3429701712,  0.2912450077, ... 
        0.1421371439, -0.0107446229, -0.0817420491, -0.0557892264, ... 
        0.0111293345,  0.0487877537,  0.0316929198, -0.0107084591, ... 
       -0.0332001728, -0.0194051637,  0.0095722932,  0.0230926689, ... 
        0.0118716883, -0.0079646002, -0.0157412783, -0.0066450326, ... 
        0.0076386917,  0.0139245827,  0.0112198257 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h2_coef.m "; fail; fi

cat > test_h3_coef.ok << 'EOF'
h3 = [  0.0019422298,  0.0169524216,  0.0338934627,  0.0342176022, ... 
        0.0046832482, -0.0410868558, -0.0593334717, -0.0052838723, ... 
        0.1230962369,  0.2669299689,  0.3391358977,  0.2886912126, ... 
        0.1437819132, -0.0065918097, -0.0795635268, -0.0579582065, ... 
        0.0069279975,  0.0470246234,  0.0341561745, -0.0067570343, ... 
       -0.0319700748, -0.0220656136,  0.0060294980,  0.0225055219, ... 
        0.0148463800, -0.0046559874, -0.0159734641, -0.0113913971, ... 
        0.0008966440,  0.0088607246,  0.0088974224 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h3_coef.m "; fail; fi

cat > test_h4_coef.ok << 'EOF'
h4 = [ -0.0012458621,  0.0159909514,  0.0333998992,  0.0356808047, ... 
        0.0075308837, -0.0387800951, -0.0591093572, -0.0071094330, ... 
        0.1206044288,  0.2651447369,  0.3382691922,  0.2879879481, ... 
        0.1425348459, -0.0081463840, -0.0805881665, -0.0580741787, ... 
        0.0070842809,  0.0463806864,  0.0323374626, -0.0089706382, ... 
       -0.0333627834, -0.0221368639,  0.0066005168,  0.0225906620, ... 
        0.0139439437, -0.0059906974, -0.0166523891, -0.0107338315, ... 
        0.0025475747,  0.0099755132,  0.0106960094 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h4_coef.m "; fail; fi

cat > test_h5_coef.ok << 'EOF'
h5 = [ -0.0051265021,  0.0016175177,  0.0105219803,  0.0112679516, ... 
       -0.0056422723, -0.0322885625, -0.0380873962,  0.0111538169, ... 
        0.1199640324,  0.2452471030,  0.3165455324,  0.2850385994, ... 
        0.1633589480,  0.0200527495, -0.0687888254, -0.0723906068, ... 
       -0.0200215870,  0.0308005828,  0.0417346601,  0.0166222841, ... 
       -0.0135491195, -0.0232109906, -0.0113637927,  0.0051353433, ... 
        0.0113227829,  0.0060896064, -0.0017160091, -0.0045556794, ... 
       -0.0022753072,  0.0007317681,  0.0013737808 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h5_coef.m "; fail; fi

cat > test_h6_coef.ok << 'EOF'
h6 = [  0.0008656281,  0.0021696544,  0.0015409094, -0.0044622917, ... 
       -0.0158159316, -0.0238564167, -0.0115295105,  0.0369399475, ... 
        0.1209482871,  0.2146857085,  0.2753128363,  0.2671184150, ... 
        0.1864131493,  0.0680195698, -0.0338776291, -0.0783792857, ... 
       -0.0609991209, -0.0114347624,  0.0303914254,  0.0408361994, ... 
        0.0229705268, -0.0030363605, -0.0182941274, -0.0172426361, ... 
       -0.0067422453,  0.0030663947,  0.0067934959,  0.0053367805, ... 
        0.0023609590,  0.0004446292, -0.0000798085 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h6_coef.m "; fail; fi

cat > test_h7_coef.ok << 'EOF'
h7 = [ -0.0125137457,  0.0049001906,  0.0228193357,  0.0309493973, ... 
        0.0089149061, -0.0355926237, -0.0585180221, -0.0092366194, ... 
        0.1195786619,  0.2683154647,  0.3441517210,  0.2918163811, ... 
        0.1413812993, -0.0120972106, -0.0822919423, -0.0549954018, ... 
        0.0123613551,  0.0490987979,  0.0307393813, -0.0119188801, ... 
       -0.0334314415, -0.0185060048,  0.0105770378,  0.0231794523, ... 
        0.0111293081, -0.0084454878, -0.0150003764, -0.0047731595, ... 
        0.0096865434,  0.0152685681,  0.0112584402 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h7_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

name_str=directFIRnonsymmetric_kyp_lowpass_alternate_test

diff -Bb test_h1_coef.ok $name_str"_h1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h1_coef.m"; fail; fi

diff -Bb test_h2_coef.ok $name_str"_h2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h2_coef.m"; fail; fi

diff -Bb test_h3_coef.ok $name_str"_h3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h3_coef.m"; fail; fi

diff -Bb test_h4_coef.ok $name_str"_h4_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h4_coef.m"; fail; fi

diff -Bb test_h5_coef.ok $name_str"_h5_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h5_coef.m"; fail; fi

diff -Bb test_h6_coef.ok $name_str"_h6_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h6_coef.m"; fail; fi

diff -Bb test_h7_coef.ok $name_str"_h7_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h7_coef.m"; fail; fi

#
# this much worked
#
pass

