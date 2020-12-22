#!/bin/sh

prog=butt3NSPA_test.m

depends="butt3NSPA_test.m test_common.m tf2pa.m tf2schurNSlattice.m \
schurNSlatticeNoiseGain.m schurNSlatticeFilter.m \
schurNSlatticeRetimedNoiseGain.m p2n60.m \
svf.m flt2SD.m x2nextra.m optKW.m tf2Abcd.m crossWelch.m print_polynomial.m \
KW.m schurexpand.oct schurdecomp.oct schurNSlattice2Abcd.oct schurNSscale.oct \
spectralfactor.oct bin2SD.oct qroots.m qzsolve.oct"

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
fc = 0.050000
n =
   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =
   1.0000  -2.3741   1.9294  -0.5321

n60 = 45
A1Star =
   1.0000  -1.6476   0.7323

A2Star =
   1.0000  -0.7265

A1 =
   0.7323  -1.6476   1.0000

A2 =
  -0.7265   1.0000

A1ng = 3.0000
A2ng = 1
A1ngABCD = 3.0000
A1ngapABCD = 3.0000
A2ngABCD = 1.0000
A2ngapABCD = 1.0000
use_exact_coefficients = 0
nbits = 10
scale = 512
ndigits = 3
A1s10f = [     -488,      376 ]/512;
A1s11f = [      158,      352 ]/512;
A1s20f = [     -488,      376 ]/512;
A1s00f = [      158,      352 ]/512;
A1s02f = [      488,     -376 ]/512;
A1s22f = [      158,      352 ]/512;
A2s10f = [     -368 ]/512;
A2s11f = [      352 ]/512;
A2s20f = [     -368 ]/512;
A2s00f = [      352 ]/512;
A2s02f = [      368 ]/512;
A2s22f = [      352 ]/512;
A1ngABCDf = 3.2501
A1ngapABCDf = 3.1899
A2ngABCDf = 0.9560
A2ngapABCDf = 0.9550
nsamples = 16384
est_varA1yd = 0.3542
varA1yd = 0.3451
est_varA2yd = 0.1630
varA2yd = 0.1632
est_varyd = 0.2543
varyd = 0.2597
est_varA1yapd = 0.3492
varA1yapd = 0.3451
est_varA2yapd = 0.1629
varA2yapd = 0.1632
est_varyapd = 0.2530
varyapd = 0.2597
A1stdxf =
   133.51   130.68

A2stdxf = 128.10
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

