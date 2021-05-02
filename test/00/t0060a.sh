#!/bin/sh

prog=casc2tf_tf2casc_test.m

depends="casc2tf_tf2casc_test.m test_common.m tf2casc.m casc2tf.m \
qroots.m qzsolve.oct"


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
tol = 1.0000e-11
casc2tf_tf2casc_test.m : a=[]
p = 1
casc2tf_tf2casc_test.m : p=1
p = 1
a = [](0x0)
k = 1
casc2tf_tf2casc_test.m : even n, real poles
a =
  -6
   9
  -4
   4
  -4
   5

k = 4
pp =
      4
    -56
    328
  -1032
   1844
  -1776
    720

casc2tf_tf2casc_test.m : odd n
p =
     6   -60   252  -576   798  -756   552  -240

a =
 Columns 1 through 6:
  -2.0000e+00  -4.0000e+00   4.0000e+00  -4.0000e+00   5.0000e+00   2.5037e-33
 Column 7:
   1.0000e+00

k = 6
pp =
 Columns 1 through 7:
     6.0000   -60.0000   252.0000  -576.0000   798.0000  -756.0000   552.0000
 Column 8:
  -240.0000

casc2tf_tf2casc_test.m : from frm2ndOrderCascade_socp.m
dk =
  -1.2724e+00
   4.0448e-01
  -2.1162e-01
   9.6246e-02
   1.9917e-01
  -1.1687e-02
   1.8722e-01
   3.0039e-03
   2.9588e-01
   5.6018e-01

d =
   1.0000e+00
  -8.0176e-01
   4.6059e-01
  -5.0283e-01
   1.2247e-01
   2.8296e-02
  -5.8264e-03
   4.8003e-03
   7.7645e-04
  -3.0982e-05
  -7.6560e-07

pr =
  -0.1479 + 0.7337i
  -0.1479 - 0.7337i
   0.6530 +      0i
   0.6194 +      0i
   0.1058 + 0.2916i
   0.1058 - 0.2916i
  -0.2466 +      0i
  -0.1695 +      0i
   0.0474 +      0i
  -0.0177 +      0i

ans =
   1.0000   0.2959   0.5602

ans =
   1.0000  -1.2724   0.4045

ans =
   1.000000  -0.211624   0.096246

ans =
   1.000000   0.416070   0.041794

ans =
   1.0000e+00  -2.9677e-02  -8.4001e-04

ans =
   1.0000  -1.2724   0.4045

ans =
   1.000000   0.416070   0.041794

ans =
   1.0000e+00  -2.9677e-02  -8.4001e-04

ans =
   1.000000  -0.211624   0.096246

ans =
   1.0000   0.2959   0.5602

dktmp =
  -1.2724e+00
   4.0448e-01
   4.1607e-01
   4.1794e-02
  -2.9677e-02
  -8.4001e-04
  -2.1162e-01
   9.6246e-02
   2.9588e-01
   5.6018e-01

k = 1
dd =
   1.0000e+00
  -8.0176e-01
   4.6059e-01
  -5.0283e-01
   1.2247e-01
   2.8296e-02
  -5.8264e-03
   4.8003e-03
   7.7645e-04
  -3.0982e-05
  -7.6560e-07

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

