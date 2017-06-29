#!/bin/sh

prog=butt6NSPABP_test.m

depends="butt6NSPABP_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
spectralfactor.oct tf2schurNSlattice.m schurNSlatticeNoiseGain.m \
schurNSlattice2Abcd.oct schurNSlatticeFilter.m schurNSlatticeRetimed2Abcd.m phi2p.m \
tfp2g.m Abcd2tf.m flt2SD.m x2nextra.m bin2SD.oct KW.m crossWelch.m tf2pa.m"

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
fc =    2.5000e-01
n =

   1.6667e-01   5.0000e-01   5.0000e-01   1.6667e-01

d =

   1.0000e+00  -3.0531e-16   3.3333e-01  -1.8504e-17

p =

   1.0000e+00  -2.7346e-01   7.2654e-01

A1BPStar =

   1.3655e+00  -7.8886e-01   2.3655e+00  -6.7309e-01   1.0000e+00

A1BP =

   1.0000e+00  -6.7309e-01   2.3655e+00  -7.8886e-01   1.3655e+00

A2BPStar =

  -1.3764e+00   3.7638e-01  -1.0000e+00

A2BP =

   1.0000e+00  -3.7638e-01   1.3764e+00

A1ng =    7.0000e+00
A2ng =    3.0000e+00
A1ngABCD =    7.0000e+00
A1ngapABCD =    7.0000e+00
A2ngABCD =    3.0000e+00
A2ngapABCD =    3.0000e+00
nbits =    1.0000e+01
scale =    5.1200e+02
ndigits =    3.0000e+00
A1s10f =

 Columns 1 through 3:

  -1.64062500000000e-01   9.53125000000000e-01  -1.48437500000000e-01

 Column 4:

   7.34375000000000e-01

A1s11f =

 Columns 1 through 3:

   9.86328125000000e-01   3.08593750000000e-01   9.88281250000000e-01

 Column 4:

   6.87500000000000e-01

A1s20f =

 Columns 1 through 3:

  -1.64062500000000e-01   9.53125000000000e-01  -1.48437500000000e-01

 Column 4:

   7.34375000000000e-01

A1s00f =

 Columns 1 through 3:

   9.86328125000000e-01   3.08593750000000e-01   9.88281250000000e-01

 Column 4:

   6.87500000000000e-01

A1s02f =

 Columns 1 through 3:

   1.64062500000000e-01  -9.53125000000000e-01   1.48437500000000e-01

 Column 4:

  -7.34375000000000e-01

A1s22f =

 Columns 1 through 3:

   9.86328125000000e-01   3.08593750000000e-01   9.88281250000000e-01

 Column 4:

   6.87500000000000e-01

A2s10f =

  -1.58203125000000e-01   7.18750000000000e-01

A2s11f =

   9.88281250000000e-01   6.87500000000000e-01

A2s20f =

  -1.58203125000000e-01   7.18750000000000e-01

A2s00f =

   9.88281250000000e-01   6.87500000000000e-01

A2s02f =

   1.58203125000000e-01  -7.18750000000000e-01

A2s22f =

   9.88281250000000e-01   6.87500000000000e-01

A1ngABCDf =    7.5062e+00
A1ngapABCDf =    7.5062e+00
A2ngABCDf =    2.8995e+00
A2ngapABCDf =    2.8995e+00
est_varA1yd =    7.0885e-01
varA1yd =    6.8465e-01
est_varA2yd =    3.2496e-01
varA2yd =    3.3069e-01
est_varyd =    3.8345e-01
varyd =    3.8520e-01
est_varA1yapd =    7.0885e-01
varA1yapd =    6.8465e-01
est_varA2yapd =    3.2496e-01
varA2yapd =    3.3069e-01
est_varyapd =    3.8345e-01
varyapd =    3.8520e-01
A1stdxf =

   1.2867e+02   1.2865e+02   1.2928e+02   1.2937e+02

A2stdxf =

   1.2674e+02   1.2657e+02

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

