#!/bin/sh

prog=casc2tf_tf2casc_test.m

depends="casc2tf_tf2casc_test.m test_common.m tf2casc.m casc2tf.m"

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
tol =    1.0000e-11
p =    1.0000e+00
p =    1.0000e+00
a = [](0x0)
k =    1.0000e+00
a =

  -4.0000e+00
   4.0000e+00
  -6.0000e+00
   9.0000e+00
  -4.0000e+00
   5.0000e+00

k =    4.0000e+00
pp =

   4.0000e+00
  -5.6000e+01
   3.2800e+02
  -1.0320e+03
   1.8440e+03
  -1.7760e+03
   7.2000e+02

p =

 Columns 1 through 6:

   6.0000e+00  -6.0000e+01   2.5200e+02  -5.7600e+02   7.9800e+02  -7.5600e+02

 Columns 7 and 8:

   5.5200e+02  -2.4000e+02

a =

 Columns 1 through 6:

  -2.0000e+00  -4.0000e+00   4.0001e+00  -4.0000e+00   5.0000e+00   7.7716e-16

 Column 7:

   1.0000e+00

k =    6.0000e+00
pp =

 Columns 1 through 6:

   6.0000e+00  -6.0000e+01   2.5200e+02  -5.7600e+02   7.9800e+02  -7.5600e+02

 Columns 7 and 8:

   5.5200e+02  -2.4000e+02

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

  -1.4794e-01 + 7.3368e-01i
  -1.4794e-01 - 7.3368e-01i
   6.5298e-01 + 0.0000e+00i
   6.1943e-01 + 0.0000e+00i
   1.0581e-01 + 2.9163e-01i
   1.0581e-01 - 2.9163e-01i
  -2.4657e-01 + 0.0000e+00i
  -1.6950e-01 + 0.0000e+00i
   4.7399e-02 + 0.0000e+00i
  -1.7722e-02 + 0.0000e+00i

ans =

   1.0000e+00   2.9588e-01   5.6018e-01

ans =

   1.0000e+00  -1.2724e+00   4.0448e-01

ans =

   1.0000e+00  -2.1162e-01   9.6246e-02

ans =

   1.0000e+00   4.1607e-01   4.1794e-02

ans =

   1.0000e+00  -2.9677e-02  -8.4001e-04

ans =

   1.0000e+00  -1.2724e+00   4.0448e-01

ans =

   1.0000e+00   4.1607e-01   4.1794e-02

ans =

   1.0000e+00  -2.9677e-02  -8.4001e-04

ans =

   1.0000e+00  -2.1162e-01   9.6246e-02

ans =

   1.0000e+00   2.9588e-01   5.6018e-01

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

k =    1.0000e+00
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
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

