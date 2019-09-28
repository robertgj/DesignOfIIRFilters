#!/bin/sh

prog=butt3NSPA_test.m

depends="butt3NSPA_test.m test_common.m tf2pa.m tf2schurNSlattice.m \
schurNSlatticeNoiseGain.m schurNSlatticeFilter.m \
schurNSlatticeRetimedNoiseGain.m \
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
fc =  0.050000
n =
   0.0028982   0.0086946   0.0086946   0.0028982

d =
   1.00000  -2.37409   1.92936  -0.53208

A1Star =
   1.00000  -1.64755   0.73234

A2Star =
   1.00000  -0.72654

A1 =
   0.73234  -1.64755   1.00000

A2 =
  -0.72654   1.00000

A1ng =  3.0000
A2ng =  1
A1ngABCD =  3.0000
A1ngapABCD =  3.0000
A2ngABCD =  1.0000
A2ngapABCD =  1.0000
use_exact_coefficients = 0
nbits =  10
scale =  512
ndigits =  3
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
A1ngABCDf =  3.2501
A1ngapABCDf =  3.1899
A2ngABCDf =  0.95605
A2ngapABCDf =  0.95500
nsamples =  16384
est_varA1yd =  0.35418
varA1yd =  0.34396
est_varA2yd =  0.16300
varA2yd =  0.16222
est_varyd =  0.25430
varyd =  0.26062
est_varA1yapd =  0.34916
varA1yapd =  0.34396
est_varA2yapd =  0.16292
varA2yapd =  0.16222
est_varyapd =  0.25302
varyapd =  0.26062
A1stdxf =
   133.64   130.73

A2stdxf =  128.18
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

