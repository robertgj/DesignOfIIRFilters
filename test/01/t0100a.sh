#!/bin/sh

prog=tfp2g_test.m

depends="tfp2g_test.m test_common.m \
phi2p.m tfp2g.m Abcd2tf.m tf2Abcd.m tfp2Abcd.m"

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
Prototype lowpass (phi=0.5)
b =
   0.090070   0.238576   0.382106   0.382106   0.238576   0.090070

a =
   1.00000  -0.66307   1.47449  -0.76804   0.53525  -0.15713

Lowpass-to-lowpass (phi=0.05)
phi =  0.050000
p =
   1.00000  -0.72654

B =
   0.0073597  -0.0184620   0.0114996   0.0114996  -0.0184620   0.0073597

A =
   1.00000  -4.50635   8.26139  -7.69076   3.63258  -0.69606

Lowpass-to-highpass (phi=0.35)
phi =  0.35000
p =
   1.00000   0.32492

B =
   0.0299981  -0.0045060   0.0364749  -0.0364749   0.0045060  -0.0299981

A =
   1.00000   2.86477   4.15821   3.41214   1.59807   0.33741

Lowpass-to-bandpass (phi=[0.2, 0.3])
phi =
   0.20000   0.30000

p =
   1.00000   0.00000   0.50953

B =
 Columns 1 through 6:
   1.6178e-02  -4.3225e-18   2.0991e-02  -1.2397e-18   1.5638e-02   1.4664e-18
 Columns 7 through 11:
  -1.5638e-02  -1.3000e-18  -2.0991e-02   3.3469e-18  -1.6178e-02

A =
 Columns 1 through 6:
   1.0000e+00   4.7712e-16   3.7791e+00   5.8487e-18   6.1915e+00  -2.2501e-16
 Columns 7 through 11:
   5.3938e+00  -2.4587e-16   2.4878e+00  -3.7119e-16   4.8469e-01

Lowpass-to-triple-bandstop (phi=[0.1 0.15 0.2 0.25 0.3 0.35])
phi =
   0.10000   0.15000   0.20000   0.25000   0.30000   0.35000

p =
   1.00000  -0.76738   1.59438  -0.91930   1.15838  -0.39100   0.32492

B =
 Columns 1 through 6:
      0.24369     -1.03453      4.15336    -11.22139     28.18173    -58.39623
 Columns 7 through 12:
    113.43968   -194.37915    314.68816   -463.13497    647.56639   -836.02130
 Columns 13 through 18:
   1029.09621  -1179.23203   1290.96751  -1320.35149   1290.96751  -1179.23203
 Columns 19 through 24:
   1029.09621   -836.02130    647.56639   -463.13497    314.68816   -194.37915
 Columns 25 through 30:
    113.43968    -58.39623     28.18173    -11.22139      4.15336     -1.03453
 Column 31:
      0.24369

A =
 Columns 1 through 5:
      1.00000000     -3.85487555     14.01904518    -34.34089357     78.02203237
 Columns 6 through 10:
   -146.38176070    256.99427258   -398.49544913    583.23966874   -777.18399005
 Columns 11 through 15:
    983.50956042  -1150.80484134   1283.56331195  -1334.03179920   1323.87195272
 Columns 16 through 20:
  -1227.75170177   1087.11101271   -898.57981044    707.74574541   -517.53174884
 Columns 21 through 25:
    358.94604965   -228.36051318    136.56313564    -73.12697353     36.15798185
 Columns 26 through 30:
    -15.20348811      5.65223281     -1.54376456      0.29647830      0.00089372
 Column 31:
     -0.01902533

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

