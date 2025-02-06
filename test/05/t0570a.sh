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
cat > test_N_6.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_6.latex.ok.lz
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
    echo "Failed output cat test_N_6.latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_6.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_6.latex.ok.lz
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
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_6.latex.ok.lz.uue"; fail;
fi

cat > test_N_7.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_7.latex.ok.lz
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
    echo "Failed output cat test_N_7.latex.ok.lz.uue"; fail;
fi

cat > test_KYP_apG_N_7.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_KYP_apG_N_7.latex.ok.lz
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
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_KYP_apG_N_7.latex.ok.lz.uue"; fail;
fi

for n in 6 7;
do 
    uudecode test_N_$n".latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_N_"$n".latex.ok.lz.uue"; fail;
    fi
    lzip -d test_N_$n".latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_N_"$n".latex.ok.lz"; fail;
    fi

    uudecode test_KYP_apG_N_$n".latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_KYP_apG_"$n".latex.ok.lz.uue"; fail;
    fi
    lzip -d test_KYP_apG_N_$n".latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_KYP_apG_N_"$n".latex.ok.lz"; fail;
    fi
done

#
# run and see if the results match. 
#
echo "Running $prog"

nstr="schurOneMlatticePipelined2Abcd_symbolic_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_6.latex.ok $nstr"_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6.latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_6.latex.ok $nstr"_KYP_apG_N_6.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_6.latex.ok"; fail; fi

diff -Bb test_N_7.latex.ok $nstr"_N_7.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_7.latex.ok"; fail; fi

diff -Bb test_KYP_apG_N_7.latex.ok $nstr"_KYP_apG_N_7.latex"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_KYP_apG_N_7.latex.ok"; fail; fi

#
# this much worked
#
pass
