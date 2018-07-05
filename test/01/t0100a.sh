#!/bin/sh

prog=tfp2g_test.m

depends="tfp2g_test.m test_common.m \
phi2p.m tfp2g.m Abcd2tf.m tf2Abcd.m tfp2Abcd.m"

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
Prototype lowpass (phi=0.5)
b =
   0.090068   0.238574   0.382103   0.382103   0.238574   0.090068

a =
   1.00000  -0.66308   1.47449  -0.76804   0.53525  -0.15713

Lowpass-to-lowpass (phi=0.05)
phi =  0.050000
p =
   1.00000  -0.72654

B =
   0.0073595  -0.0184614   0.0114992   0.0114992  -0.0184614   0.0073595

A =
   1.00000  -4.50635   8.26139  -7.69076   3.63258  -0.69606

Lowpass-to-highpass (phi=0.35)
phi =  0.35000
p =
   1.00000   0.32492

B =
   0.0299974  -0.0045066   0.0364744  -0.0364744   0.0045066  -0.0299974

A =
   1.00000   2.86477   4.15821   3.41214   1.59807   0.33741

Lowpass-to-bandpass (phi=[0.2, 0.3])
phi =
   0.20000   0.30000

p =
   1.00000   0.00000   0.50953

B =
 Columns 1 through 6:
   1.6178e-02   5.7613e-18   2.0990e-02  -4.0543e-18   1.5637e-02  -6.1028e-18
 Columns 7 through 11:
  -1.5637e-02  -9.3909e-18  -2.0990e-02  -6.7369e-18  -1.6178e-02

A =
 Columns 1 through 6:
   1.0000e+00   4.5228e-16   3.7791e+00   4.5335e-17   6.1915e+00  -8.3626e-17
 Columns 7 through 11:
   5.3938e+00  -9.4602e-17   2.4878e+00  -3.6741e-16   4.8469e-01

Lowpass-to-triple-bandstop (phi=[0.1 0.15 0.2 0.25 0.3 0.35])
phi =
   0.10000   0.15000   0.20000   0.25000   0.30000   0.35000

p =
   1.00000  -0.76738   1.59438  -0.91930   1.15838  -0.39100   0.32492

B =
 Columns 1 through 6:
      0.24369     -1.03452      4.15333    -11.22132     28.18155    -58.39588
 Columns 7 through 12:
    113.43902   -194.37806    314.68645   -463.13252    647.56304   -836.01707
 Columns 13 through 18:
   1029.09109  -1179.22624   1290.96121  -1320.34506   1290.96121  -1179.22624
 Columns 19 through 24:
   1029.09109   -836.01707    647.56304   -463.13252    314.68645   -194.37806
 Columns 25 through 30:
    113.43902    -58.39588     28.18155    -11.22132      4.15333     -1.03452
 Column 31:
      0.24369

A =
 Columns 1 through 5:
      1.00000000     -3.85487460     14.01903787    -34.34086592     78.02194534
 Columns 6 through 10:
   -146.38155026    256.99381341   -398.49459358    583.23819237   -777.18171622
 Columns 11 through 15:
    983.50627377  -1150.80050539   1283.55790210  -1334.02556423   1323.86512644
 Columns 16 through 20:
  -1227.74475758   1087.10428760   -898.57375049    707.74054504   -517.52760741
 Columns 21 through 25:
    358.94291253   -228.35832394    136.56168652    -73.12610259     36.15748763
 Columns 26 through 30:
    -15.20324068      5.65211664     -1.54371946      0.29646200      0.00089771
 Column 31:
     -0.01902625

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

