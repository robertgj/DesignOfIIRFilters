#!/bin/sh

prog=ellipMinQ_test.m

depends="ellipMinQ_test.m test_common.m flt2SD.m x2nextra.m bin2SDul.m \
bin2SD.oct"

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
cat > test.ok << 'EOF'
Fp =  0.10000
ApdB =  0.10000
Fa =  0.12500
AadB =  40
n =  9
nbits =  8
ndigits =  3
-0.809017 < a < -0.707107. Choose a=-0.750000
x0 =  1.3333
f3dB =  0.11503
a1 = -0.45142
fa =  0.12500
fp =  0.10571
wa =  1.2010
k =  0.83263
g=3.13294e-05
L =  31918.88137
apdB =  0.00013606
aadB =  45.041
abs(ps)=[ 1.095908 1.095908 1.095907 1.095907 1.095906 1.095906 1.095906 1.095906 1.095908 ], expected 1.095906
abs(pz-x0)=[ 0.881918 0.881918 0.881918 0.881918 0.881917 0.881917 0.881917 0.881917 0.881918 ]
b=[ 0.350740 0.619208 0.822345 0.949033 ]
alpha=[ -0.749999 -0.749999 -0.750000 -0.750000 -0.750000 ], expected -0.750000
Response at f3dB=0.115027 is -2.965440 dB
Response at fp=0.105715 is -0.000151 dB
Response at fa=0.125000 is -45.040719 dB
p=1,mbin=0000, max. stop band response=-33.318381 dB at 0.183875
p=2,mbin=0001, max. stop band response=-24.214429 dB at 0.127937
p=3,mbin=0010, max. stop band response=-20.488492 dB at 0.125000
p=4,mbin=0011, max. stop band response=-26.100887 dB at 0.139313
p=5,mbin=0100, max. stop band response=-29.594366 dB at 0.178750
p=6,mbin=0101, max. stop band response=-23.189315 dB at 0.128375
p=7,mbin=0110, max. stop band response=-21.073759 dB at 0.125000
p=8,mbin=0111, max. stop band response=-28.321003 dB at 0.138188
p=9,mbin=1000, max. stop band response=-39.116625 dB at 0.130437
p=10,mbin=1001, max. stop band response=-25.039035 dB at 0.127625
p=11,mbin=1010, max. stop band response=-20.091820 dB at 0.125000
p=12,mbin=1011, max. stop band response=-24.508943 dB at 0.141000
p=13,mbin=1100, max. stop band response=-34.016691 dB at 0.131250
p=14,mbin=1101, max. stop band response=-23.938354 dB at 0.128000
p=15,mbin=1110, max. stop band response=-20.649861 dB at 0.125000
p=16,mbin=1111, max. stop band response=-26.375324 dB at 0.139938
SD response at f3dB=0.115027 is -2.987061 dB
SD response at fp=0.105715 is -0.000723 dB
SD response at fa=0.125000 is -41.711562 dB
8 bit, 3 signed-digit, p=9, a1=-58, a=-96, b=[ 46 79 104 121 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok ellipMinQ_test.diary
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
