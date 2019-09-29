#!/bin/sh

prog=butt6NSPABP_test.m

depends="butt6NSPABP_test.m test_common.m tf2schurNSlattice.m \
schurNSlatticeNoiseGain.m schurNSlatticeFilter.m \
schurNSlatticeRetimedNoiseGain.m phi2p.m tfp2g.m Abcd2tf.m \
flt2SD.m x2nextra.m KW.m crossWelch.m tf2pa.m print_polynomial.m \
bin2SD.oct schurexpand.oct schurdecomp.oct schurNSscale.oct spectralfactor.oct \
schurNSlattice2Abcd.oct qroots.m qzsolve.oct"

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
fc =  0.25000
n =
   0.16667   0.50000   0.50000   0.16667

d =
   1.0000e+00  -3.0531e-16   3.3333e-01  -1.8504e-17

p =
   1.00000  -0.27346   0.72654

A1BPStar =
   1.36549  -0.78886   2.36549  -0.67309   1.00000

A1BP =
   1.00000  -0.67309   2.36549  -0.78886   1.36549

A2BPStar =
  -1.37638   0.37638  -1.00000

A2BP =
   1.00000  -0.37638   1.37638

A1ng =  7.0000
A2ng =  3.0000
A1ngABCD =  7.0000
A1ngapABCD =  7.0000
A2ngABCD =  3.0000
A2ngapABCD =  3.0000
use_exact_coefficients = 0
nbits =  10
scale =  512
ndigits =  3
A1s10f = [      -84,      488,      -76,      376 ]/512;
A1s11f = [      505,      158,      506,      352 ]/512;
A1s20f = [      -84,      488,      -76,      376 ]/512;
A1s00f = [      505,      158,      506,      352 ]/512;
A1s02f = [       84,     -488,       76,     -376 ]/512;
A1s22f = [      505,      158,      506,      352 ]/512;
A2s10f = [      -81,      368 ]/512;
A2s11f = [      506,      352 ]/512;
A2s20f = [      -81,      368 ]/512;
A2s00f = [      506,      352 ]/512;
A2s02f = [       81,     -368 ]/512;
A2s22f = [      506,      352 ]/512;
A1ngABCDf =  7.5062
A1ngapABCDf =  7.5062
A2ngABCDf =  2.8995
A2ngapABCDf =  2.8995
est_varA1yd =  0.70885
varA1yd =  0.68465
est_varA2yd =  0.32496
varA2yd =  0.33069
est_varyd =  0.38345
varyd =  0.38520
est_varA1yapd =  0.70885
varA1yapd =  0.68465
est_varA2yapd =  0.32496
varA2yapd =  0.33069
est_varyapd =  0.38345
varyapd =  0.38520
A1stdxf =
   128.67   128.65   129.28   129.37

A2stdxf =
   126.74   126.57

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

