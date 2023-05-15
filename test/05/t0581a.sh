#!/bin/sh

prog=butt3OneMPA_test.m

depends="test/butt3OneMPA_test.m test_common.m tf2pa.m tf2schurOneMlattice.m \
schurOneMscale.m schurOneMAPlattice2Abcd.m schurOneMPAlatticeAsq.m \
allpass_GM1_pole2coef.m allpass_GM1_coef2Abcd.m \
allpass_GM2_pole2coef.m allpass_GM2_coef2Abcd.m \
qroots.m H2Asq.m \
schurexpand.oct schurdecomp.oct qzsolve.oct spectralfactor.oct Abcd2H.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct complex_zhong_inverse.oct"

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
tol = 1.0000e-10
fc = 200
fs = 48000
n =
   0.9742  -2.9225   2.9225  -0.9742

d =
   1.0000  -2.9476   2.8966  -0.9490

k = -0.9742
e = -1
a = 0.9742
b = 1.9742
c = 0.025843
dd = -0.9742
k1 = -0.9997
k2 = 0.9742
e1 = -1
e2 = -1
a2 =
   9.9966e-01   1.9997e+00
  -3.3382e-04   9.7383e-01

b2 =
          0
   0.025839

c2 =
   6.7650e-04  -1.9735e+00

d2 = 0.9742
n =
   2.1853e-06   6.5560e-06   6.5560e-06   2.1853e-06

d =
   1.0000  -2.9476   2.8966  -0.9490

A1Star =
   1.0000  -1.9735   0.9742

A2Star =
   1.0000  -0.9742

A1 =
   0.9742  -1.9735   1.0000

A2 =
  -0.9742   1.0000

A1k =
  -0.9997   0.9742

A1epsilon =
  -1  -1

A1p =
   8.7394   0.1144

A1c =
   6.7650e-04  -1.9735e+00   9.7416e-01

A1S =
   0.0059        0        0
  -0.2258   0.2259        0
   0.9742  -1.9735   1.0000

A2k = -0.9742
A2epsilon = -1
A2p = 8.7401
A2c =
   0.025843  -0.974157

A2S =
   0.2259        0
  -0.9742   1.0000

A1sv =
   0.999657   0.026177
  -0.025501   0.973827

B1sv =
        0
   0.2259

C1sv =
   5.9122e-03  -2.2578e-01

D1sv = 0.9742
A2sv = 0.9742
B2sv = 0.2259
C2sv = 0.2259
D2sv = -0.9742
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

