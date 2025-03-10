#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelined2Abcd_kyp_symbolic_test.m
depends="test/schurOneMPAlatticeDoublyPipelined2Abcd_kyp_symbolic_test.m \
test_common.m tf2pa.m qroots.oct Abcd2tf.m \
schurOneMPAlatticeDelay_wise_lowpass.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
spectralfactor.oct schurdecomp.oct"

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
cat > test_N_3.ok.lz.uue << 'EOF'
begin-base64 644 test_N_3.ok.lz
TFpJUAFQACadSoYi7GhZqUcnZIVefIhTQAknmhPHKJrVMeXCkin9jcthXP6K
6/ZGDpMyqkhXliXSDV51L7OKE8ig/+vJqQ3Vij7N3WP05pnBwx4/JXPnypSq
hM8uYKwwSX8lTe4Ya/m7OnlM0LPFHb8dJodgbREdXMy6sEx1vdJSRkThR9UB
WcOvZq40CqZujxnqTSiSdq7ThDzp4ihQ57FSCXBLCO1+uENSjRsvSPgDxPCH
RaBYpSKGWXhm01xOQOoa7DWDMK28NBh+EI12Piylc0KeilQq9t/HiJreNOgK
+DukinzPfiwXbBsg7V2zhn0c/cTWASv37kKavjD0k7xaZtjUXGSmHFJv5pDI
OaJ/FLibM57SPiiM9U2MpnOt9B7NDSeOI+7/+atXf9VyGQrKcXJ1EamMIxR9
TzitnEOeCHROy0+bb/Tf1lPkcVpg+xEVMJqqFmC6+/6gDdgYFBl1Bw8vu+bx
E/9Mt86HTfc/jF7ocVh0YWk2Hy2RPZKOSpTbuBF+/CLk0/N9P63MV9TCSMfW
De4LDHlwY2cSwO7Sb9rbRZ9WnKuhmnipOBvJ4CrcwHrRIF0Vtr0Jqk2g7GgA
XAOHEGaFS3w8DtZCv6Oj3nvMtwVPP8LFs9Vt+5ntsuD71A+LYWKwCqtzFFln
Rh4nmaeJdTxRHmFUhGFQMiO2dLtUB5AFrWqHixw7qY3Dc37i1/ac3qbhxcoh
u6sSLcPrrm/L2CemkEe/29F1xWqRBbQ//IGctkcCaKtEyvV9Oo6ZuTqo4VqD
5JMN37Ex3GW5M1t/SH+qc5/t1d/CnNMXFA89cpxW2DfAzuDk9nmIitwi5voS
TZac9rbfslTr3HwiK9haMLkJw6Y3Ju7wmp68+VeTU7j11BaIQLNg1thl53J5
EdXn5F40uBBbtsKyOApLE7eKEB9ppXkP2hMzmuzKAo69jtQonXxoCFbUCJ0M
5vcr3TOw0Xk23aEXfPnV7OpzxneY4Mw84J+SjeTC6mDggKnxk3mknQ41R/5L
7WcwnbRoN9whvoB6gICm0hEKVBaOBohrG+hUvTc3SCqrFm0hVBBa8W+9AB57
KbHHKLLLIDZhyD2rz+OBlHyCpKGPVjod7ns3IWJzfrQJprvvdQ+R00+si+SJ
yxIhHZX72o2iLc+JCopM6qyTVvZDaEUk1T0o+UNClZYSB4n9/NJcPDcLPVLW
cxO589ZKg69rl/7EMaXLuM+yL6eJ7Udv0ISDSlJ/mtJVuxXf9p34DBv1+PQ6
tBmRcxrV+VDYdu9QdkwLyz3AsZ+l+SgfOh1eosVNE/+zvR1j8pAmS85QQYuU
J3vFqYc/WMi2LXRXDDhVWxE0TAMl0Qw2yVZM3geqaL1NxAjqIH0j/58c3Fw0
iqgivXt5oG+TZAUF3q357/nV8nJ+zhgxlJIR8KsOcd7B7kIM5ziGak7giiFg
NJafdQmuztUzO5KKNOUwhdNaAMUafhRnzbnt8pbk6FU6XFoGCrnNxtR/14ca
sBD2av+FYA4mDJSavx7F6i5eoEF3DDnhwUBOe2z9P9UiIU25BQXCmiyW4J76
Pb4rBrClhOzdH+iu8KI9p55Mw7qcJykkysb5wGjYhsdTAd9tLZmdRQZ2B61y
xdJfj9YDzXH3oCLPHHOO9S0CQFGvlx88xFskzS+YVNrTUGaODMd71wb/PL2F
RxCdT1rd2exzPlY7EgsmVJ6R80bQJpu28RGtiHacyfgZBlXHBPa2VyFlr+Qy
Afu42PL5N7kh3mVle5JUHAJmPbn7ij4Ny+5O1rtfHjoIq2A2ElpzbjSqe7ti
6tzZrm512VCXI6gz5nCqJaQ/U7VkOuTm9WKlmxR4pJGSnPBht2e/X6DuoJAe
UHN7Jb5GEPMsRuYemmYp/YKiuhNl/HyMNSR90eQKdnmFl8T8McaLxDcEfzQl
YuLNsgCWWbOPRD7BcXtqZcuvMjSGHWRdGSj0wnQV3caXFCmLOW89v5jxt8J0
LPy+mmCuHbx7HVrnxynbFAoGjE0zMOTN8Qpl7U1xJyvx8yXlGOQ9/vparU+P
1SIsjWHILpMfEPT+DVKjrLhxDAU20EiU3ok9jENBOIF7crYcqtVfaq8YK6pG
ZEe25M7tc5afYVwCSsG/ZlyhcOBEK/tfnmSlZ4+Yr6B36JeFfDwRNKvS/m6C
EiC8RxO/Mi35ULQmuPhopqjZ13oODfiwQPv/suD41LP3QWqrE8hoJAebF3bJ
ZTF31Lhh5H2xmECmPGA6UEyelRzBCJTlfhXbuBtRNftsgOCEWSZmduhh+RFB
M6O4zAsAIb4cCV6OtD0kOVk3YmxNWPWW02xE9jhKJI7ekVD6LzqhOKExEIq5
pXSmD0v2YX8VpKz0ObsqpMKGRGlI4ZKJeZD1gFI9HhZRC8cUovu6ZMoNf1lC
MebCoj4e1VFCtUpRyLI/vnV9B8pmXNp2INq+U4vDoqrHKuNshaf09hPoAFVd
jL7QrSdRmEMcDbE0VdmXDWRfzYBOReutQDT8o59gyJykBad0RpvzhC74xujS
FhQkPjMJsPR6wwEH/PiB26N44nTJuWBxwYEAwjvPT6hByQshoctZT9UbDDjw
Lx9bBYELWGL27xGE7eNx7NEoIplZFiFdSDmVSpsX9Bg3X+UAaHBb1Qy8xtES
sHQwfPJyiW6YQ1YUYd4twQwLWA78LyRZDqxsH2Md6vJSmfKuyOWOozOaJf6X
MxmWVdiWauLgqVb0TSZcj0+2CN7fdw9/9AWBwjp97tNMYv+joAN9E89v3cAc
PM3zx7WI2wBRU6jSis3yzgBBwIg+ZCJsOMacRe2Pr0bZZYrMhZ+jXvWZqAwY
aiQomSSdYtTBVssi08xrZBUuvZwnHwJMj3Gq9Fxokm5MlXT0SSylQZSzfD+7
lmbqw0Wixsigrq1MMxbR2S+smajH92Ro3QfmpxYVSkqhpT8jr65P04bbzR1/
5Z5UfjYwh0rbiDTZmPGHK6XSck0j3cWQr48eckPJG/8E9AVIDgET4gwfvHR+
36j68Vi2E/lapl9r4puGrtgPMuDmbkaTw+m9qMWOrZpnE2loFzkYGzOUaHRi
eUjwiWy7WqrUWXsjHK5wlJNxQIIcNRWXAJ7zMzIqnphaw23LxW8U4a0RreVW
f218/azEHsf0+iHVB1SVZeJpHa2gz9urb8Oe5GUPI2ew2HSdEZMhz7vO+Sfr
09eB00ix48kxqHHoXAlg1Ghlc5O44T/HvXs7pPZgcnQsjNFEZuKaoIldYW9g
nU179lIFACZZR5QDhQRf41t4OGqrdYNWrzZlVxWzxLpNC7bv4hYlVOIeakXT
gug113+15DfTlhIl0mGm6/2+cv7Fnv9Yvx7EsgPBQPnJGGlXRhNVYpZy8IQl
3YfBfv4VC+w8QVMkYVeJmWDaQ/lpPTumExAdWy/vWIwD2PVS25ZEUf+c5nCX
xgOTvmvBVQGCW9xM3kar+vILP8+KcAMNZO1gNed0+G5xxXlxYEdExrVFKMWl
GMrJVSogO1ecc+JGc+XJRgPbMiM1Knumd6trjTmUYTFl3uPwUs0tBTS2Q9+8
KRVGAt6plbEC1iv5CR2uAQt7B+idoIaNTE568S43eeF+8JXAfU7LgcZyOJIB
0eqCje/bmIN1pT3/6nlz1TxYzdAc3QAAAAAAALAKAAAAAAAA
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_3.ok.lz.uue"; fail;
fi
uudecode test_N_3.ok.lz.uue
if [ $? -ne 0 ]; then
    echo "Failed uudecode test_N_3.ok.lz.uue"; fail;
fi
lzip -d test_N_3.ok.lz
if [ $? -ne 0 ]; then
    echo "Failed lzip -d test_N_3.ok.lz"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlatticeDoublyPipelined2Abcd_kyp_symbolic_test"

diff --strip-trailing-cr -wBb test_N_3.ok $nstr"_K_Theta_N_3.py"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_3.ok"; fail; fi

#
# this much worked
#
pass
