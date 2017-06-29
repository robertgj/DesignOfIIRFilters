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
   2.4369e-01  -1.0345e+00   4.1533e+00  -1.1221e+01   2.8182e+01  -5.8396e+01
 Columns 7 through 12:
   1.1344e+02  -1.9438e+02   3.1469e+02  -4.6313e+02   6.4756e+02  -8.3602e+02
 Columns 13 through 18:
   1.0291e+03  -1.1792e+03   1.2910e+03  -1.3203e+03   1.2910e+03  -1.1792e+03
 Columns 19 through 24:
   1.0291e+03  -8.3602e+02   6.4756e+02  -4.6313e+02   3.1469e+02  -1.9438e+02
 Columns 25 through 30:
   1.1344e+02  -5.8396e+01   2.8182e+01  -1.1221e+01   4.1533e+00  -1.0345e+00
 Column 31:
   2.4369e-01
A =
 Columns 1 through 6:
   1.0000e+00  -3.8549e+00   1.4019e+01  -3.4341e+01   7.8022e+01  -1.4638e+02
 Columns 7 through 12:
   2.5699e+02  -3.9849e+02   5.8324e+02  -7.7718e+02   9.8351e+02  -1.1508e+03
 Columns 13 through 18:
   1.2836e+03  -1.3340e+03   1.3239e+03  -1.2277e+03   1.0871e+03  -8.9857e+02
 Columns 19 through 24:
   7.0774e+02  -5.1753e+02   3.5894e+02  -2.2836e+02   1.3656e+02  -7.3126e+01
 Columns 25 through 30:
   3.6157e+01  -1.5203e+01   5.6521e+00  -1.5437e+00   2.9646e-01   8.9771e-04
 Column 31:
  -1.9026e-02
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

