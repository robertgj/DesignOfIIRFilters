#!/bin/sh

prog=butt3NSPA_test.m

depends="butt3NSPA_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct spectralfactor.oct tf2pa.m \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m \
schurNSlattice2Abcd.oct schurNSlatticeFilter.m schurNSlatticeRetimed2Abcd.m \
svf.m flt2SD.m x2nextra.m bin2SD.oct KW.m optKW.m tf2Abcd.m crossWelch.m"

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

A1Star =

   1.0000e+00  -1.6476e+00   7.3234e-01

A2Star =

   1.0000e+00  -7.2654e-01

A1 =

   7.3234e-01  -1.6476e+00   1.0000e+00

A2 =

  -7.2654e-01   1.0000e+00

A1ng =    3.0000e+00
A2ng =    1.0000e+00
A1ngABCD =    3.0000e+00
A1ngapABCD =    3.0000e+00
A2ngABCD =    1.0000e+00
A2ngapABCD =    1.0000e+00
nbits =    1.0000e+01
scale =    5.1200e+02
ndigits =    3.0000e+00
A1s10f =

  -9.53125000000000e-01   7.34375000000000e-01

A1s11f =

   3.08593750000000e-01   6.87500000000000e-01

A1s20f =

  -9.53125000000000e-01   7.34375000000000e-01

A1s00f =

   3.08593750000000e-01   6.87500000000000e-01

A1s02f =

   9.53125000000000e-01  -7.34375000000000e-01

A1s22f =

   3.08593750000000e-01   6.87500000000000e-01

A2s10f =   -7.18750000000000e-01
A2s11f =    6.87500000000000e-01
A2s20f =   -7.18750000000000e-01
A2s00f =    6.87500000000000e-01
A2s02f =    7.18750000000000e-01
A2s22f =    6.87500000000000e-01
A1ngABCDf =    3.2501e+00
A1ngapABCDf =    3.1899e+00
A2ngABCDf =    9.5605e-01
A2ngapABCDf =    9.5500e-01
nsamples =    1.6384e+04
est_varA1yd =    3.5418e-01
varA1yd =    3.4396e-01
est_varA2yd =    1.6300e-01
varA2yd =    1.6222e-01
est_varyd =    2.5430e-01
varyd =    2.6062e-01
est_varA1yapd =    3.4916e-01
varA1yapd =    3.4396e-01
est_varA2yapd =    1.6292e-01
varA2yapd =    1.6222e-01
est_varyapd =    2.5302e-01
varyapd =    2.6062e-01
A1stdxf =

   1.3364e+02   1.3073e+02

A2stdxf =    1.2818e+02
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

