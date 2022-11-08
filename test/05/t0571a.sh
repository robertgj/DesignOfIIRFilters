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
cat > test_N_4_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_4_latex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k8L5/nQ+9ofZjpJCjfTwoZWT6P
2sFz7ecL53AQQ9Mh/MuBlhMcVVke7LMu9sfn+a4eP7vFu2pd8xiyLPwBylVL
3BnhPWVhqC+Au9P/c6jC6gn+SZ9pT3wtlhvqu7vwrAG6R81y9FOof//toq5g
uNxHaTABAAAAAAAAmwAAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_4_latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_4_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_4_latex.ok.lz
TFpJUAEMADCcBOi0m+Pjl2PFMDZmpeVYC5j6CFJ74yn0ek+qTsGmR+MlqvLn
AdUGZwKiQrGWtjPBYsEMMq1l5ufJLofB6vDFiZ+1eRrhsqoKNT8SWjmwFhuj
ABZrkyRMDJYu5KtzQX01h3hDQX9Siyt8xkMkf9fNjgYXv8sIQ9v4NUNLG8vp
T6gw4k+unajPDOW3LRLUU9vrnPMaUULp0lMLexfxKIN5iru6fJbMiGIYv2ql
xAAD4x9wTScVMzwI05NZHO3TUqLZFKo6VTWTrD2ZZfnbMGp9C3A9dKkPzdeN
x4zYX0KkNo/igX30HlraYuL3VvNzSX5HGsq2/rr8HBLQgIht1kDFxsU/ydRX
krmw0RtjaJo5fnwuTpshjHSa/ioSQP6xV1Lg5reG5pxwxHU7TlQHqr4f89jf
6s5QDLGfxMBA0bnxdktrDBZkjpBjEmo2ge/5QC0wrEZqCtuGUPcdhwEgzTsW
kFpWqtlhrpbJzBpdWAStVc6gYiTmn3dThnW/09ncSFOUYE+QlaKkE8t6hZ37
RzClsldlcmM08uBtOkfOj5/pEbjrg5dZpYy0MFA+3vSSRv860q5uB/hpeDbx
9BQBm9Wgf/vCZFuMdsUH8w0AAAAAAADhAQAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_4_latex.ok.lz.uue"; fail;
fi

cat > test_N_6_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_6_latex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k8L5/nQ+9ofZjpJCjfTwoZzfqU
mDaeCQOHerclOGEjK0DUPUMZ5/vHIrtbpWJ/N0KtTHGzTS+KZ39wiYFAmbzL
9f+gIzvfw5UQRQpfX/xy5iCQnCpRILE2nhXxB+N38SFZLRAn/yOXiDRK/eFn
DTNzZd1qAprAXurDQAP8OkeCMVab//+fYE3gofEBLh0CAAAAAAAAtgAAAAAA
AAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_6_latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_6_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_6_latex.ok.lz
TFpJUAHuADCcBOi0m+Pjl2PFMDZmpeVYC5j6CFJ74yn0ek+qTsGmR+MlqvLn
AdUGZwKiQrGWtjPBYsEMMq1l5ufJLofB6vDFiZ+1eRrhtwt7q+fXYAQv6Ze7
8zSIzayJsv246LgQQoV9ovZ1VmomCEdiEV9ezaH6gQas+JuyFgeURQkm1pTD
I4VQYVuLfvqV31MdNjGKylV379VFpIg+kFY0PBsf2NxpI7Qsst85WpgDmqRS
HBW1B1bS38lQQ+pImxBTKXDot1MIJeLPPPDZRJKzC8kcA5LdTtuPxQXWkDPq
8rtFVWevBv/gfOXoSoaVrFqnXBtfBfWY7+n5kWdXiYKTbTI/By3Wrr4XVBUE
mNZ1pkYl8egzrhSznt/y/EkeTfjRqD2RUdJHsXybxW9Ifd6zOTGKOahOK9wS
P8Sz6E3zsH2pLbBYZpF4Iiyoj1jE8Q42+7ScgrsUhnDc1RkPQJP9BOq/0T0N
7NnCo0D2LzBFqMfQlW4dfduJEWrF589GaG8vBo2Iu4zh4/5Zj0eflQE/J5qn
JKcCOIJOjrNrC5Hut/t+DoBfq1v/URz4byRyFA1OWGG16Wg612WduEiIqFRg
L5kIW59nqz8Gr88gxVESNrPF96SA8eae8X96hQhDm25k6YV4gqYUAj2eyPAc
scJLa8TfvLgL81kVq5mbLS4vEL6KYyYOT/HB0xjPLOOaLifSamqvtBIHWmfy
3X+IXOT+V1QleRC5pOJ3/RYVCZhYuYlT7+OfAfr/2c59ax1bvMOTdjNcJS1z
pAbwYTGfMiDc6Ez4/pZ1i1H3UYkmvxr9Suzyxnz+5e09EH03H14b8VrAzVDP
saULj0AH90eYUFcALpMPadx3kczxO47gs6Z5kCsdDy2QJ++9BmgQn5WnH+3e
g76swhQJGIjodEAV/0+c1Esc+IM/CqhyFAbKVQhCNHICEM0IguqyYa+uilT9
hpID07c4Y+Q1Z1DbK1QAmrbx6QH0lsx4RTw7gKPfaGb5TAsicvsiUUEWVDhd
4Q9kJKzhJi1kCQDlj0hg/m/L1L57zkRM+wzOSqfodkMXBQPa0Q9NVXWDgdM/
CYQG0yykMu6XpCl6z7Ihofmb2DOZfK+iz/6gQu7/7kvFdPfnpn1lIwAAAAAA
AGADAAAAAAAA
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_6_latex.ok.lz.uue"; fail;
fi

cat > test_N_12_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_12_latex.ok.lz
TFpJUAEMACCQhHa6APVkpNhAdmReM+f5D6k7IW7DBxnCmh7wQ66nfVMl7RF6
3f4OYrheBNeE7UxGtBxQmwLOIrQJkmNRyliVNKgP4z5OFMwWDGW6jhhLXVrR
HPs0i63gxo/2cw8T0jgSrI8Pcqv10zXsq8T7V8zxEfQPY/nOjhaGeqY3IXRp
NxZ2mlvpPYyaskWIG1/vWz72ShDunqxOkTFm5mVH9/mQwrg1COSdgD8KsIog
RuJAunNgsHOQKkM1HENG4bLZSzxjcOmniRTYgCILr11IEZlg3yCH6OviChTc
9BA94nlPhtzLtswaTXDkQOst/9Cscq2Th4zPtQYAAAAAAAAMAQAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_12_latex.ok.lz.uue"; fail;
fi

cat > test_N_20_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_20_latex.ok.lz
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
    echo "Failed output cat test_N_20_latex.ok.lz.uue"; fail;
fi

for n in 4 6 12 20;
do 
    uudecode test_N_$n"_latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_N_"$n"_latex.ok.lz.uue"; fail;
    fi
    lzip -d test_N_$n"_latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_N_"$n"_latex.ok.lz"; fail;
    fi
done

for n in 4 6;
do 
    uudecode test_KYP_apG_N_$n"_latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_KYP_apG_"$n"_latex.ok.lz.uue"; fail;
    fi
    lzip -d test_KYP_apG_N_$n"_latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_KYP_apG_N_"$n"_latex.ok.lz"; fail;
    fi
done


#
# run and see if the results match. 
#
echo "Running $prog"

strf="schurOneMR2lattice2Abcd_symbolic_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_4_latex.ok $strf"_N_4.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_4_latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_4_latex.ok $strf"_KYP_apG_N_4.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_4_latex.ok"; fail; fi

diff -Bb test_N_6_latex.ok $strf"_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6_latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_6_latex.ok $strf"_KYP_apG_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_6_latex.ok"; fail; fi

diff -Bb test_N_12_latex.ok $strf"_N_12.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_12_latex.ok"; fail; fi

diff -Bb test_N_20_latex.ok $strf"_N_20.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_20_latex.ok"; fail; fi

#
# this much worked
#
pass
