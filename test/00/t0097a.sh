#!/bin/sh

prog=butt3OneMSV_test.m

depends="butt3OneMSV_test.m test_common.m \
schurexpand.oct schurdecomp.oct bin2SD.oct x2nextra.m flt2SD.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m \
schurOneMlattice2Abcd.oct schurOneMlatticeRetimedNoiseGain.m \
schurOneMlatticeFilter.m KW.m optKW.m svf.m crossWelch.m"

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
k =

  -9.7432e-01   9.2923e-01  -5.3208e-01

epsilon =

  -1.0000e+00  -1.0000e+00  -1.0000e+00

p =

   3.0386e+00   3.4657e-01   1.8095e+00

c =

   1.0050e-01   2.9862e-01   1.0166e-02   2.8982e-03

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
ng =    9.8228e-01
ngap =    5.0000e+00
ngABCD =    7.5000e-01
ngABCDap =    3.0000e+00
ngDecim =    1.1906e+00
ngDecimap =    5.0000e+00
ngPipe =    7.5000e-01
ngPipeap =    3.0000e+00
ngopt =    4.7049e-01
ngoptap =    3.0000e+00
nbits =    1.0000e+01
scale =    5.1200e+02
ndigits =    3.0000e+00
kf =

  -9.765625000000000e-01   9.296875000000000e-01  -5.312500000000000e-01

cf =

 Columns 1 through 3:

   1.015625000000000e-01   2.968750000000000e-01   9.765625000000000e-03

 Column 4:

   1.953125000000000e-03

ngf =    1.1019e+00
ngfap =    5.0000e+00
ngABCDf =    8.4725e-01
ngABCDfap =    3.0000e+00
ngPipef =    8.4725e-01
ngPipefap =    3.0000e+00
est_varyd =    1.7516e-01
varyd =    1.7410e-01
est_varyapd =    5.0000e-01
varyapd =    4.9283e-01
stdxf =

   1.3706e+02   1.2904e+02   1.2782e+02

est_varyABCDd =    1.5394e-01
varyABCDd =    1.5147e-01
est_varyABCDapd =    3.3333e-01
varyABCDapd =    3.2012e-01
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

