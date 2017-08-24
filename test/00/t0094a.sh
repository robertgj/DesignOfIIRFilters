#!/bin/sh

prog=butt3NS_test.m

depends="butt3NS_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlattice2Abcd.oct \
schurNSlatticeFilter.m svf.m KW.m optKW.m tf2Abcd.m crossWelch.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
fc =    5.0000e-02
n =

   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =

   1.0000e+00  -2.3741e+00   1.9294e+00  -5.3208e-01

s10 =

   3.2096e-01   5.6957e-02   2.8982e-03

s11 =

   9.4709e-01   9.9838e-01   3.2297e-01

s20 =

  -9.7432e-01   9.2923e-01  -5.3208e-01

s00 =

   2.2518e-01   3.6951e-01   8.4670e-01

s02 =

   9.7432e-01  -9.2923e-01   5.3208e-01

s22 =

   2.2518e-01   3.6951e-01   8.4670e-01

c =

   3.0538e-01   1.0349e-01   1.8395e-02   2.8982e-03

S =

   7.0452e-02   0.0000e+00   0.0000e+00   0.0000e+00
  -3.0483e-01   3.1286e-01   0.0000e+00   0.0000e+00
   7.8677e-01  -1.5915e+00   8.4670e-01   0.0000e+00
  -5.3208e-01   1.9294e+00  -2.3741e+00   1.0000e+00

ng =    1.1906e+00
ngap =    5.0000e+00
A =

   9.7432e-01   2.2518e-01   0.0000e+00
  -2.0925e-01   9.0536e-01   3.6951e-01
   4.4273e-02  -1.9156e-01   4.9442e-01

B =

   0.0000e+00
   0.0000e+00
   8.4670e-01

C =

   3.0538e-01   1.0349e-01   1.8395e-02

D =    2.8982e-03
Cap =

   7.0452e-02  -3.0483e-01   7.8677e-01

Dap =   -5.3208e-01
K =

   1.0000e+00  -1.7764e-15   9.7145e-16
  -1.7764e-15   1.0000e+00  -2.3315e-15
   9.7145e-16  -2.3315e-15   1.0000e+00

W =

   3.0944e-01   2.3626e-01   1.0521e-01
   2.3626e-01   2.9506e-01   1.8969e-01
   1.0521e-01   1.8969e-01   1.4550e-01

ngABCD =    7.5000e-01
Kap =

   1.0000e+00  -1.7764e-15   9.7145e-16
  -1.7764e-15   1.0000e+00  -2.3315e-15
   9.7145e-16  -2.3315e-15   1.0000e+00

Wap =

   1.0000e+00  -1.9429e-15  -2.8588e-15
  -1.9429e-15   1.0000e+00  -3.4972e-15
  -2.8588e-15  -3.4972e-15   1.0000e+00

ngABCDap =    3.0000e+00
ngopt =    4.7049e-01
ngoptap =    3.0000e+00
ngdir =    6.8980e+01
ngdirap =    8.1890e+02
est_varyd =    1.8255e-01
varyd =    1.8266e-01
est_varyABCDd =    1.4583e-01
varyABCDd =    1.4448e-01
est_varyoptd =    1.2254e-01
varyoptd =    1.1981e-01
est_varydird =    5.8317e+00
varydird =    1.8078e+00
est_varyapd =    5.0000e-01
varyapd =    4.9645e-01
stdxx =

   1.3132e+02   1.2947e+02   1.2797e+02

stdxxopt =

   1.3045e+02   1.2949e+02   1.3104e+02

stdxxdir =

   1.3132e+02   1.3132e+02   1.3132e+02

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

