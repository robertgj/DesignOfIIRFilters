#!/bin/sh

prog=butt3NSSV_test.m

depends="butt3NSSV_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlatticeRetimed2Abcd.m \
schurNSlatticeFilter.m KW.m flt2SD.m x2nextra.m bin2SD.oct crossWelch.m"

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

ng =    1.1906e+00
ngap =    5.0000e+00
nbits =    1.0000e+01
scale =    5.1200e+02
ndigits =    2.0000e+00
s10f =

   3.12500000000000e-01   5.46875000000000e-02   1.95312500000000e-03

s11f =

   9.37500000000000e-01   9.98046875000000e-01   3.12500000000000e-01

s20f =

  -9.68750000000000e-01   9.37500000000000e-01  -5.31250000000000e-01

s00f =

   2.18750000000000e-01   3.75000000000000e-01   8.75000000000000e-01

s02f =

   9.68750000000000e-01  -9.37500000000000e-01   5.31250000000000e-01

s22f =

   2.18750000000000e-01   3.75000000000000e-01   8.75000000000000e-01

ngf =    1.1334e+00
ngfap =    5.6989e+00
est_varyd =    1.7778e-01
varyd =    1.7627e-01
est_varyapd =    5.5824e-01
varyapd =    5.5307e-01
stdxf =

   1.3421e+02   1.3504e+02   1.3249e+02

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

