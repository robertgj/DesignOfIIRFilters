#!/bin/sh

prog=svcasc2noise_example_test.m

depends="svcasc2noise_example_test.m test_common.m \
svcasc2noise.m butter2pq.m pq2svcasc.m pq2blockKWopt.m \
svcasc2Abcd.m KW.m optKW2.m optKW.m svcascf.m svf.m crossWelch.m"

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

Butterworth low-pass filter with N=20, fc=0.100000
xbits =

 Columns 1 through 6:

   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00

 Columns 7 through 10:

  -0.0000e+00  -0.0000e+00   0.0000e+00   0.0000e+00

stdydirf =

 Columns 1 through 6:

   3.5030e+02   6.7611e+02   9.1500e+02   9.0059e+02   7.6001e+02   5.3286e+02

 Columns 7 through 10:

   3.5274e+02   2.3100e+02   1.5957e+02   1.1932e+02

stdxx1dirf =

 Columns 1 through 6:

   6.3838e+01   6.4133e+01   6.6489e+01   6.6030e+01   6.8010e+01   6.5967e+01

 Columns 7 through 10:

   6.5025e+01   6.4667e+01   6.5595e+01   6.6575e+01

stdxx2dirf =

 Columns 1 through 6:

   6.3839e+01   6.4136e+01   6.6490e+01   6.6031e+01   6.8015e+01   6.5967e+01

 Columns 7 through 10:

   6.5031e+01   6.4667e+01   6.5606e+01   6.6593e+01

varyddirf =    6.5502e+01
est_varyddirf =    9.0674e+01
stdyboptf =

 Columns 1 through 6:

   3.5090e+02   6.8265e+02   9.0847e+02   9.1126e+02   7.6012e+02   5.4583e+02

 Columns 7 through 10:

   3.6162e+02   2.3650e+02   1.6140e+02   1.2024e+02

stdxx1boptf =

 Columns 1 through 6:

   6.3834e+01   6.4837e+01   6.5687e+01   6.7650e+01   6.7485e+01   6.9474e+01

 Columns 7 through 10:

   6.7229e+01   6.6440e+01   6.6252e+01   6.6591e+01

stdxx2boptf =

 Columns 1 through 6:

   6.3898e+01   6.4753e+01   6.5938e+01   6.6939e+01   6.7925e+01   6.7807e+01

 Columns 7 through 10:

   6.6755e+01   6.6271e+01   6.6384e+01   6.7126e+01

varydboptf =    2.0351e+01
est_varydboptf =    2.1937e+01
stdyboptfx =

 Columns 1 through 6:

   3.5100e+02   6.8279e+02   9.0857e+02   9.1135e+02   7.6018e+02   5.4589e+02

 Columns 7 through 10:

   3.6170e+02   2.3656e+02   1.6141e+02   1.2026e+02

stdxx1boptfx =

 Columns 1 through 6:

   1.2769e+02   1.2968e+02   1.3137e+02   1.3532e+02   1.3498e+02   1.3897e+02

 Columns 7 through 10:

   6.7252e+01   6.6445e+01   6.6262e+01   6.6596e+01

stdxx2boptfx =

 Columns 1 through 6:

   1.2782e+02   1.2953e+02   1.3189e+02   1.3389e+02   1.3586e+02   1.3563e+02

 Columns 7 through 10:

   6.6773e+01   6.6289e+01   6.6388e+01   6.7139e+01

varydboptfx =    6.3163e+00
est_varydboptfx =    7.4054e+00
est_varydGoptf =    2.3102e+00
varydGoptf =    2.3693e+00
stdyGoptf =    1.1491e+02
stdxxGoptf =

 Columns 1 through 6:

   6.4068e+01   6.4365e+01   6.3374e+01   6.2388e+01   6.4105e+01   6.3807e+01

 Columns 7 through 12:

   6.4043e+01   6.4693e+01   6.4110e+01   6.3015e+01   6.4012e+01   6.4856e+01

 Columns 13 through 18:

   6.4013e+01   6.3930e+01   6.3233e+01   6.4194e+01   6.3429e+01   6.3997e+01

 Columns 19 and 20:

   6.4668e+01   6.5720e+01


Butterworth high-pass filter with N=20, fc=0.100000
xbits =

 Columns 1 through 6:

   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00

 Columns 7 through 10:

  -0.0000e+00  -0.0000e+00   0.0000e+00   0.0000e+00

stdydirf =

 Columns 1 through 6:

   4.1666e+02   7.2434e+02   9.4075e+02   9.8165e+02   8.0454e+02   6.1241e+02

 Columns 7 through 10:

   4.5257e+02   3.3910e+02   2.7054e+02   2.3061e+02

stdxx1dirf =

 Columns 1 through 6:

   6.3838e+01   6.2562e+01   6.2796e+01   6.5297e+01   6.2861e+01   6.3224e+01

 Columns 7 through 10:

   6.4225e+01   6.4630e+01   6.5003e+01   6.4855e+01

stdxx2dirf =

 Columns 1 through 6:

   6.3839e+01   6.2564e+01   6.2796e+01   6.5297e+01   6.2861e+01   6.3225e+01

 Columns 7 through 10:

   6.4225e+01   6.4631e+01   6.5004e+01   6.4857e+01

varyddirf =    6.1327e+01
est_varyddirf =    8.1968e+01
stdyboptf =

 Columns 1 through 6:

   4.1718e+02   7.5087e+02   9.8471e+02   9.8438e+02   8.3766e+02   6.3023e+02

 Columns 7 through 10:

   4.6124e+02   3.4444e+02   2.7238e+02   2.3162e+02

stdxx1boptf =

 Columns 1 through 6:

   6.3973e+01   6.5177e+01   6.5832e+01   6.5745e+01   6.6306e+01   6.5530e+01

 Columns 7 through 10:

   6.5750e+01   6.5883e+01   6.5366e+01   6.5252e+01

stdxx2boptf =

 Columns 1 through 6:

   6.3954e+01   6.5119e+01   6.4774e+01   6.6748e+01   6.6601e+01   6.6472e+01

 Columns 7 through 10:

   6.5240e+01   6.5876e+01   6.5551e+01   6.5050e+01

varydboptf =    2.0341e+01
est_varydboptf =    2.1574e+01
stdyboptfx =

 Columns 1 through 6:

   4.1684e+02   7.4999e+02   9.8352e+02   9.8329e+02   8.3694e+02   6.2977e+02

 Columns 7 through 10:

   4.6104e+02   3.4437e+02   2.7237e+02   2.3162e+02

stdxx1boptfx =

 Columns 1 through 6:

   1.2781e+02   1.3017e+02   1.3148e+02   1.3132e+02   1.3247e+02   1.3091e+02

 Columns 7 through 10:

   6.5697e+01   6.5853e+01   6.5342e+01   6.5248e+01

stdxx2boptfx =

 Columns 1 through 6:

   1.2777e+02   1.3004e+02   1.2934e+02   1.3331e+02   1.3304e+02   1.3279e+02

 Columns 7 through 10:

   6.5166e+01   6.5841e+01   6.5523e+01   6.5036e+01

varydboptfx =    7.2464e+00
est_varydboptfx =    7.5025e+00
est_varydGoptf =    2.3490e+00
varydGoptf =    2.3436e+00
stdyGoptf =    2.2853e+02
stdxxGoptf =

 Columns 1 through 6:

   6.4008e+01   6.3527e+01   6.3733e+01   6.3798e+01   6.4665e+01   6.4068e+01

 Columns 7 through 12:

   6.3969e+01   6.3349e+01   6.3772e+01   6.3837e+01   6.4329e+01   6.4030e+01

 Columns 13 through 18:

   6.4300e+01   6.3560e+01   6.4180e+01   6.4487e+01   6.4309e+01   6.4127e+01

 Columns 19 and 20:

   6.4162e+01   6.3533e+01

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.out"; fail; fi

#
# this much worked
#
pass
