#!/bin/sh

prog=tfp2g_test.m

depends="test/tfp2g_test.m test_common.m \
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
   1.0000  -0.6631   1.4745  -0.7680   0.5353  -0.1571

Lowpass-to-lowpass (phi=0.05)
phi = 0.050000
p =
   1.0000  -0.7265

B =
   7.3597e-03  -1.8462e-02   1.1500e-02   1.1500e-02  -1.8462e-02   7.3597e-03

A =
   1.0000  -4.5064   8.2614  -7.6908   3.6326  -0.6961

Lowpass-to-highpass (phi=0.35)
phi = 0.3500
p =
   1.0000   0.3249

B =
   2.9998e-02  -4.5060e-03   3.6475e-02  -3.6475e-02   4.5060e-03  -2.9998e-02

A =
   1.0000   2.8648   4.1582   3.4121   1.5981   0.3374

Lowpass-to-bandpass (phi=[0.2, 0.3])
phi =
   0.2000   0.3000

p =
   1.0000        0   0.5095

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
   0.1000   0.1500   0.2000   0.2500   0.3000   0.3500

p =
   1.0000  -0.7674   1.5944  -0.9193   1.1584  -0.3910   0.3249

B =
 Columns 1 through 6:
   2.4369e-01  -1.0345e+00   4.1534e+00  -1.1221e+01   2.8182e+01  -5.8396e+01
 Columns 7 through 12:
   1.1344e+02  -1.9438e+02   3.1469e+02  -4.6313e+02   6.4757e+02  -8.3602e+02
 Columns 13 through 18:
   1.0291e+03  -1.1792e+03   1.2910e+03  -1.3204e+03   1.2910e+03  -1.1792e+03
 Columns 19 through 24:
   1.0291e+03  -8.3602e+02   6.4757e+02  -4.6313e+02   3.1469e+02  -1.9438e+02
 Columns 25 through 30:
   1.1344e+02  -5.8396e+01   2.8182e+01  -1.1221e+01   4.1534e+00  -1.0345e+00
 Column 31:
   2.4369e-01

A =
 Columns 1 through 6:
   1.0000e+00  -3.8549e+00   1.4019e+01  -3.4341e+01   7.8022e+01  -1.4638e+02
 Columns 7 through 12:
   2.5699e+02  -3.9850e+02   5.8324e+02  -7.7718e+02   9.8351e+02  -1.1508e+03
 Columns 13 through 18:
   1.2836e+03  -1.3340e+03   1.3239e+03  -1.2278e+03   1.0871e+03  -8.9858e+02
 Columns 19 through 24:
   7.0775e+02  -5.1753e+02   3.5895e+02  -2.2836e+02   1.3656e+02  -7.3127e+01
 Columns 25 through 30:
   3.6158e+01  -1.5203e+01   5.6522e+00  -1.5438e+00   2.9648e-01   8.9372e-04
 Column 31:
  -1.9025e-02

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

