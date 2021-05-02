#!/bin/sh

prog=butt6NSPABP_test.m

depends="butt6NSPABP_test.m test_common.m tf2schurNSlattice.m \
schurNSlatticeNoiseGain.m schurNSlatticeFilter.m \
schurNSlatticeRetimedNoiseGain.m phi2p.m tfp2g.m Abcd2tf.m \
flt2SD.m x2nextra.m KW.m crossWelch.m tf2pa.m print_polynomial.m \
bin2SD.oct schurexpand.oct schurdecomp.oct schurNSscale.oct spectralfactor.oct \
schurNSlattice2Abcd.oct p2n60.m qroots.m qzsolve.oct"

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
fc = 0.2500
n =
   0.1667   0.5000   0.5000   0.1667

d =
   1.0000e+00  -3.0531e-16   3.3333e-01  -1.8504e-17

n60 = 13
p =
   1.0000  -0.2735   0.7265

A1BPStar =
   1.3655  -0.7889   2.3655  -0.6731   1.0000

A1BP =
   1.0000  -0.6731   2.3655  -0.7889   1.3655

A2BPStar =
  -1.3764   0.3764  -1.0000

A2BP =
   1.0000  -0.3764   1.3764

A1ng = 7.0000
A2ng = 3.0000
A1ngABCD = 7.0000
A1ngapABCD = 7.0000
A2ngABCD = 3.0000
A2ngapABCD = 3.0000
use_exact_coefficients = 0
nbits = 10
scale = 512
ndigits = 3
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
A1ngABCDf = 7.5062
A1ngapABCDf = 7.5062
A2ngABCDf = 2.8995
A2ngapABCDf = 2.8995
est_varA1yd = 0.7088
varA1yd = 0.6892
est_varA2yd = 0.3250
varA2yd = 0.3305
est_varyd = 0.3835
varyd = 0.3889
est_varA1yapd = 0.7088
varA1yapd = 0.6892
est_varA2yapd = 0.3250
varA2yapd = 0.3305
est_varyapd = 0.3835
varyapd = 0.3889
A1stdxf =
   128.73   128.70   129.30   129.40

A2stdxf =
   126.75   126.58

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

