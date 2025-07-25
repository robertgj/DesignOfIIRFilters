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
   0.092029   0.248848   0.399772   0.399772   0.248848   0.092029

a =
   1.0000  -0.6044   1.4236  -0.6959   0.4969  -0.1388

Lowpass-to-lowpass (phi=0.05)
phi = 0.050000
p =
   1.0000  -0.7265

B =
   7.4865e-03  -1.8652e-02   1.1597e-02   1.1597e-02  -1.8652e-02   7.4865e-03

A =
   1.0000  -4.4839   8.1810  -7.5806   3.5642  -0.6799

Lowpass-to-highpass (phi=0.35)
phi = 0.3500
p =
   1.0000   0.3249

B =
   3.0587e-02  -6.6150e-03   3.8235e-02  -3.8235e-02   6.6150e-03  -3.0587e-02

A =
   1.0000   2.8109   4.0297   3.2640   1.5106   0.3145

Lowpass-to-bandpass (phi=[0.2, 0.3])
phi =
   0.2000   0.3000

p =
   1.0000        0   0.5095

B =
 Columns 1 through 6:
   1.6457e-02   2.5938e-18   2.0562e-02  -8.3542e-18   1.5734e-02  -1.2271e-17
 Columns 7 through 11:
  -1.5734e-02  -1.7435e-17  -2.0562e-02  -6.9201e-18  -1.6457e-02

A =
 Columns 1 through 6:
   1.0000e+00   3.4737e-16   3.7381e+00   9.9769e-17   6.0669e+00   3.4451e-17
 Columns 7 through 11:
   5.2383e+00  -1.5234e-16   2.3951e+00  -4.9866e-16   4.6243e-01

Lowpass-to-triple-bandstop (phi=[0.1 0.15 0.2 0.25 0.3 0.35])
phi =
   0.1000   0.1500   0.2000   0.2500   0.3000   0.3500

p =
   1.0000  -0.7674   1.5944  -0.9193   1.1584  -0.3910   0.3249

B =
 Columns 1 through 6:
   2.4802e-01  -1.0538e+00   4.2343e+00  -1.1449e+01   2.8774e+01  -5.9662e+01
 Columns 7 through 12:
   1.1597e+02  -1.9882e+02   3.2204e+02  -4.7416e+02   6.6322e+02  -8.5648e+02
 Columns 13 through 18:
   1.0545e+03  -1.2086e+03   1.3232e+03  -1.3534e+03   1.3232e+03  -1.2086e+03
 Columns 19 through 24:
   1.0545e+03  -8.5648e+02   6.6322e+02  -4.7416e+02   3.2204e+02  -1.9882e+02
 Columns 25 through 30:
   1.1597e+02  -5.9662e+01   2.8774e+01  -1.1449e+01   4.2343e+00  -1.0538e+00
 Column 31:
   2.4802e-01

A =
 Columns 1 through 6:
   1.0000e+00  -3.8613e+00   1.4067e+01  -3.4517e+01   7.8560e+01  -1.4764e+02
 Columns 7 through 12:
   2.5965e+02  -4.0329e+02   5.9124e+02  -7.8910e+02   1.0002e+03  -1.1722e+03
 Columns 13 through 18:
   1.3095e+03  -1.3633e+03   1.3553e+03  -1.2594e+03   1.1176e+03  -9.2617e+02
 Columns 19 through 24:
   7.3174e+02  -5.3714e+02   3.7437e+02  -2.3971e+02   1.4460e+02  -7.8384e+01
 Columns 25 through 30:
   3.9448e+01  -1.7050e+01   6.6320e+00  -1.9788e+00   4.7680e-01  -5.0003e-02
 Column 31:
  -5.4586e-03

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

