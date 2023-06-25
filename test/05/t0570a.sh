#!/bin/sh

prog=schurOneMlatticePipelined2Abcd_symbolic_test.m
depends="test/schurOneMlatticePipelined2Abcd_symbolic_test.m \
test_common.m schurOneMlatticePipelined2Abcd.m tf2schurOneMlattice.m tf2Abcd.m \
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
cat > test_N_6_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_6_latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ103QEUHvO5SVETZST+wWHgXs6r
YbXuTVw93uTZYYDDGuvik+5jWhnMPc/5/rZ32mqiXSQOzofwDlwH9J+e+xrb
yrinlwgmW0/cmElRGHSJwT+zXW9GCSKcwi26h5wAy40rdkfm5nX+dz6nZhgE
R461GnlQOajFeEGd20ZvxQ6GVrUF8mjJ5xv3mmT0CI8wgxvRcSU9C6bmbjS3
73u1s/OAK2S8/yTqT+bkfqglsTT3wTl4ddcQeyYVXPDQoLN4ppG0NUuBEh9v
6ALQ0iOVm75wdZO0KA/8xlpqUxumZ8hdH8kvdzTv52+ZGorefY+a5Ymv8Rf1
108ZtJ4CT/uI50AWtpZjy86t1qaq/QATJd9gb8vcrfuKGlaW+7iRI7/9/3zD
kKEIix4JAAAAAAAATwEAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_6_latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_6_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_6_latex.ok.lz
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
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_6_latex.ok.lz.uue"; fail;
fi

cat > test_N_7_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_7_latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ1w8xnlxYqdE6SAuy3CUH6+9/5W
qhfCfL8W+v4nfrk3NpAu529j+QxOEassdtuI+9MV67EfON2EX1hdHVyV7M0W
TdvGugueZFsTiIpAKWHRB4XKPdxs3q+kxLj9Ws8xUdtavR9KROyeoxKNtKtt
gZpm5TNp+ubys/F4UwDRdfOSailDnxmkbPqzynMqUDR4+VLJZtkfBYYBR4f7
jgQzvNxWFlPj8X4nCiYopWzff2lyKofcj4majm3QXX0sVqHbJXjn+41zUVpO
kalQy9uvvBAcAL8XdT/IBF1pdDSSEC763m6O1BCRPQEPhyKO8w6r6g4plplt
PfAapzAwTJc50tDAoTmstC1rTwt6WL6+0QRbVqwCpOF/mXGQF3LYOlFXxtUP
oBPuGanVrZfFDZPl8bpJMAn2oeKody3AafzlaDWy8m0mUNqmSa3uhv/0uzzN
B48LuNsKAAAAAAAAfAEAAAAAAAA=
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_7_latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_7_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_7_latex.ok.lz
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
rPmGODxH3wAAAAAAALoPAAAAAAAA
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_7_latex.ok.lz.uue"; fail;
fi

for n in 6 7;
do 
    uudecode test_N_$n"_latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_N_"$n"_latex.ok.lz.uue"; fail;
    fi
    lzip -d test_N_$n"_latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_N_"$n"_latex.ok.lz"; fail;
    fi

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

strf="schurOneMlatticePipelined2Abcd_symbolic_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_6_latex.ok $strf"_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6_latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_6_latex.ok $strf"_KYP_apG_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_6_latex.ok"; fail; fi

diff -Bb test_N_7_latex.ok $strf"_N_7.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_7_latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_7_latex.ok $strf"_KYP_apG_N_7.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_7_latex.ok"; fail; fi

#
# this much worked
#
pass
