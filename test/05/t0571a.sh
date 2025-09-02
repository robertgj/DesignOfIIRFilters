#!/bin/sh

prog=schurOneMR2lattice2Abcd_symbolic_test.m
depends="test/schurOneMR2lattice2Abcd_symbolic_test.m \
test_common.m schurOneMR2lattice2Abcd.m tf2schurOneMlattice.m tf2Abcd.m \
Abcd2tf.m schurOneMscale.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct"

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
cat > test_N_4.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_4.tex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k8L5/nQ+9ofZjpJCjfTwoZWT6P
2sFz7ecL53AQQ9Mh/MuBlhMcVVke7LMu9sfn+a4eP7vFu2pd8xiyLPwBylVL
3BnhPWVhqC+Au9P/c6jC6gn+SZ9pT3wtlhvqu7vwrAG6R81y9FOof//toq5g
uNxHaTABAAAAAAAAmwAAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_4.tex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_4.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_4.tex.ok.lz
TFpJUAEMADCcBOi0m+Pjl2PFMDZmpeVYC5j6CFJ74yn0ek+qTsGmR+MlqvLn
AdUGZwKiQrGWtjPBYsEMMq1l5ufJLofMkqEtrDvoKm98CiiMK8BCG7Wvu/GR
ecyeztB3lYLkayzyvu/dPC+PAiIwjQ0FN6jaDscTt8Cz8ygy8tAmulW9MsVq
3xp1qKYU9LtYV+WbkrH/m3yFWRb2S59gVFnS3tRUHqUkaYmkKA6ap7jxOtXk
K236kUlvGyIM+whVoJ5ztkml/cHFXz8Q4UYatpY40OFmY48YtMj4rMM8FiQ+
5CG3VevDO6O1gLbNR3AaNLgx9NOPa5od8HwUr3LBrwbLotKvqK6NIDAiwp4p
Iv3Lxbg6g3/BpL3mzcXVi/blBQEmo+Z+MiMW40YdCcyRkMWxwd+QbnP630Ne
+jQ2NL7jX/kAPH14rJ52wrevrWwyGVnM09HCW3l4QYpaXDf6YbWwdY3omsFn
XJ4RZ1vK7qlviSXCt8xzH0gCWM6YKPPlJMejN3SnyPGoko5W2s03/tHQAPMg
mcn8Wh+fuGefyFuf+bBGWdw+szcvWtBye8x1io3+kT9W3aKDkMcMAAAAAAAA
ygEAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_4.tex.ok.lz.uue"; fail;
fi

cat > test_N_6.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_6.tex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k8L5/nQ+9ofZjpJCjfTwoZzfqU
mDaeCQOHerclOGEjK0DUPUMZ5/vHIrtbpWJ/N0KtTHGzTS+KZ39wiYFAmbzL
9f+gIzvfw5UQRQpfX/xy5iCQnCpRILE2nhXxB+N38SFZLRAn/yOXiDRK/eFn
DTNzZd1qAprAXurDQAP8OkeCMVab//+fYE3gofEBLh0CAAAAAAAAtgAAAAAA
AAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_6.tex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_6.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_6.tex.ok.lz
TFpJUAHuADCcBOi0m+Pjl2PFMDZmpeVYC5j6CFJ74yn0ek+qTsGmR+MlqvLn
AdUGZwKiQrGWtjPBYsEMMq1l5ufJLofMkqEtr3tGs3d2E+37lQHlj1rPLa1o
Bvlbr75WtMZ4NntolsF6cOSF08EWIZWKcVlhCHnWUmBnGMip7ZE82iZrPU0E
Y6DHMt67px0HGE4EGEOzLxEf4jYHoMUxRulnXdA+FwxgTOoSKCJIELjjkJLh
8ZL1hqUE6fJtk44BK4Zlw1zA3GGHo3bGBE/8oaCgJ9hifaNyMjHlY5Vpd8gg
J1bdgKuf25TPVFMr0Un9W9nVrtyTQAGiog+fw+/CnMDu7c6/JYvfcTQIg0PM
0+h6ESdeg4OhwDOLWldXDVXDO5AxGP81JEOprF3548te/kuCeynlPVXQop57
WXI/NqQTdATgMxMwScUh/bGPqDefGbSqSTrzNsFnvqoIOEjz7St0/Bt3qJ2N
i/yTSLsIiH3lwAM7dzNfey5RNKEttyhAmhvodMyZmxLgshyxk0tMZuKnVPwC
8E6VP6WHn9rL7C7FMwcxsOtdKtLTNT0LC5xZkNviQgDzr0tC6u5Peobkj6UB
DQhWlTmFVak7at3shxS8hFvKMgo//DgFnWsOMmDkGsOTolb6u6FBfWYFHo7D
5c/pQHg7QJ48YtX16Qz9duP0XMvD6x0ABklnzWz6vJljCzNhJVcViJtFL7cj
mihGIlNnODxOmfs0A4rpo8dFlpeGPr0Ht5Egw9k62DyF68ygIAeYCtynrKhM
HIdArf5ADXQjXmm02oQNo9hNCKwmvpAr/LHeR56bMBBeLYiG1jQg8S5XuYFV
/WSTkbT50aAPk0CqTf5L1kxCAE8VpSkbcD4ZxWKXSQgiE6PVZNGJLMclrh5W
tUBt//A67FtjaMI+R5f400UULDsYTrQ8LgmvmzK9Q9Qob5PXqWSYN3+8usFQ
/P71tiCNWfrWimUQzLAP7tONEk5OyhC5IlLTHdYH3YHUYmZBZjqtaIMNMF3s
qG3y0WL3YuzN93vvFuDRN0a2pQUg/5t1Q93s+8yhTSAAAAAAAAArAwAAAAAA
AA==
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_6.tex.ok.lz.uue"; fail;
fi

cat > test_N_12.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_12.tex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k7IW7DBxnCmh7wQ66nfVMl7RF6
3f4OYrheBNeE7UxGtBxQmwLOIrQJkmNRyliVNKgP4z5OFMwWDGW6jhhLXVrR
HPs0i63gxo/2cw8T0jgSrI8Pcqv10zXsq8T7V8zxEfQPY/nOjhaGeqY3IXRp
NxZ2mlvpPYyaskWIG1/vWz72ShDunqxOkTFm5mVH9/mQwrg1COSdgD8KsIog
RuJAunNgsHOQKkM1HENG4bLZSzxjcOmniRTYgCILr11IEZlg3yCH6OviChTc
9BA94nlPhtzLtswaTXDkQOst/9Cscq2Th4zPtQYAAAAAAAAMAQAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_12.tex.ok.lz.uue"; fail;
fi

cat > test_N_20.tex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_20.tex.ok.lz
TFpJUAHtACCQhHa6APVkpNhAdmReM+f5D6k7IW7DBxnCmh9cMZ8/DzYzqA0A
1GqYZmTNxppwciTO6r/lEjtKmVwbNgc/UlMNueMLmtCKb89PvOqkaxlz0oTU
7U+HurU0yAXnBpwNlVl+8SgWh8hQG7A/LzlAqse3fnJcwBWY1uTxuVTI/bi4
kZoslM0Fl6dLldLxTgPR16bfeCRRRCUuiKnjpQ5tNAUPQ0b2rXOA13+gdGqS
Ln7u+QOrcnfP7szhBoNqqRStNkKG+YRS6wt0cl8KGgUxACUdv804tu9Sl75X
RlWVpmizahFqjMfwCuGLFe2bKOQKJoQZui7WdzJQAi1E5/+T04cWCGi/CdRr
sZYN0KNMWQlsAFdN2vcHL7yvdmMfGpb009S4Q9bHxi7w3oAJLxaNgCgtxpg6
VBnFbQg6rCeUbCNvn1ro82Lrpv0ZFPXhvqiCpLv/9+yvdNXCl8DFEAAAAAAA
AHEBAAAAAAAA
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_20.tex.ok.lz.uue"; fail;
fi

for n in 4 6 12 20;
do 
    uudecode test_N_$n".tex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_N_"$n".tex.ok.lz.uue"; fail;
    fi
    lzip -d test_N_$n".tex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_N_"$n".tex.ok.lz"; fail;
    fi
done

for n in 4 6;
do 
    uudecode test_KYP_apG_N_$n".tex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_KYP_apG_"$n".tex.ok.lz.uue"; fail;
    fi
    lzip -d test_KYP_apG_N_$n".tex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_KYP_apG_N_"$n".tex.ok.lz"; fail;
    fi
done


#
# run and see if the results match. 
#
echo "Running $prog"

nstr="schurOneMR2lattice2Abcd_symbolic_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_4.tex.ok $nstr"_N_4.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_4.tex.ok"; fail; fi

diff -Bb test_KYP_apG_N_4.tex.ok $nstr"_KYP_apG_N_4.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_4.tex.ok"; fail; fi

diff -Bb test_N_6.tex.ok $nstr"_N_6.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6.tex.ok"; fail; fi

diff -Bb test_KYP_apG_N_6.tex.ok $nstr"_KYP_apG_N_6.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_6.tex.ok"; fail; fi

diff -Bb test_N_12.tex.ok $nstr"_N_12.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_12.tex.ok"; fail; fi

diff -Bb test_N_20.tex.ok $nstr"_N_20.tex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_20.tex.ok"; fail; fi

#
# this much worked
#
pass
