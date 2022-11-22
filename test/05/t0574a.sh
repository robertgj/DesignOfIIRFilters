#!/bin/sh

prog=complementaryFIRlattice2Abcd_symbolic_test.m
depends="test/complementaryFIRlattice2Abcd_symbolic_test.m test_common.m \
complementaryFIRlattice2Abcd.m Abcd2tf.m complementaryFIRlattice.m \
minphase.m direct_form_scale.m complementaryFIRdecomp.oct"

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
cat > test_N_10_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_10_latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ1w8xnlxYqdE6SAvNP4WO0+Bexx
8bpnoNqJdYyAPSOVMliJRFdh/Cm/KrduKQrFGKSBp3ZuKgBtDZCnfbKdvx4v
X1NzrB8x8cus9pCgZv6fvKre8iUH7j/pUV+j6CkIBH6cyF0w9v6eQW80lkyg
7bvSaaPpkyRnFHZf9XRf03lsc5p5d0Hbm5nwfYAAKBkiytQSQxzRvME/7Igr
Tq5CVbIQmP80eYD+F8XVTV+TjpMndnef+e3HbQ++qogYq6Bp21mLbThnYhRL
zCRliw7FO1x5/xbvZrhI+HEWJ7/pBlhS7D6SObSp5yBGpJrxPe1Lqllw7gWy
FT7hMc/uFsKGbHapMh8IYLYNwerDl6UpLNHz8CHIYdMZQe6yr62oPMDL9/js
gDymcOQGUOv1gGa2JStf/EhJJwHA/GnWotpDeoOofT76G7eZsTfagtAQI2Py
2ugt9ldzIYPZg5ZECZW+G1NCpmKd4GcWlblq09w0dkMKmKWK6+cdKEzGDNok
vjG4aKC3YF2FA//+pWqOGNsZ2P4MAAAAAAAAuAEAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_10_latex.ok.lz.uue"; fail;
fi

uudecode test_N_10_latex.ok.lz.uue
if [ $? -ne 0 ]; then
    echo "Failed uudecode test_N_10_latex.ok.lz.uue"; fail;
fi

lzip -d test_N_10_latex.ok.lz
if [ $? -ne 0 ]; then
    echo "Failed lzip -d test_N_10_latex.ok.lz"; fail;
fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_10_latex.ok complementaryFIRlattice2Abcd_symbolic_test_N_10.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_10_latex.ok"; fail; fi

#
# this much worked
#
pass
