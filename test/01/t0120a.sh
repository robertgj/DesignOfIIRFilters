#!/bin/sh

prog=butt5NSSD_test.m

depends="butt5NSSD_test.m test_common.m \
spectralfactor.oct schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m flt2SD.m x2nextra.m bin2SD.oct schurNSlatticeFilter.m \
crossWelch.m tf2pa.m"

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
n =

   5.9796e-05   2.9898e-04   5.9796e-04   5.9796e-04   2.9898e-04   5.9796e-05

d =

   1.0000e+00  -3.9845e+00   6.4349e+00  -5.2536e+00   2.1651e+00  -3.5993e-01

Aap1 =

   1.0000e+00  -1.5217e+00   6.0000e-01

Aap2 =

   1.0000e+00  -2.4629e+00   2.0872e+00  -5.9988e-01

S =

   4.5849e-01   9.5463e-02   1.3576e-02   1.8070e-03   5.9796e-05

s10 =

   8.8870e-01   9.9543e-01   9.9991e-01   1.0000e+00   3.1866e-01

s11 =

  -9.8041e-01   9.7875e-01  -9.5809e-01   8.3977e-01  -3.5993e-01

s20 =

   1.9698e-01   2.0507e-01   2.8647e-01   5.4294e-01   9.3298e-01

s00 =

   9.8041e-01  -9.7875e-01   9.5809e-01  -8.3977e-01   3.5993e-01

s02 =

   1.9698e-01   2.0507e-01   2.8647e-01   5.4294e-01   9.3298e-01

s22 =

   2.8187e-01   1.4542e-01   3.0417e-02   4.3262e-03   5.7583e-04   5.9796e-05

c =

   5.8617e-03   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
  -2.9174e-02   2.9757e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.4203e-01  -2.8151e-01   1.4511e-01   0.0000e+00   0.0000e+00   0.0000e+00
  -4.8532e-01   1.4373e+00  -1.4577e+00   5.0655e-01   0.0000e+00   0.0000e+00
   7.8349e-01  -3.1485e+00   4.8704e+00  -3.4355e+00   9.3298e-01   0.0000e+00
  -3.5993e-01   2.1651e+00  -5.2536e+00   6.4349e+00  -3.9845e+00   1.0000e+00

nbits =    1.0000e+01
scale =    5.1200e+02
ndigits =    2.0000e+00
A1s10f =

  -9.37500000000000e-01   6.25000000000000e-01

A1s11f =

   3.12500000000000e-01   7.50000000000000e-01

A1s20f =

  -9.37500000000000e-01   6.25000000000000e-01

A1s00f =

   3.12500000000000e-01   7.50000000000000e-01

A1s02f =

   9.37500000000000e-01  -6.25000000000000e-01

A1s22f =

   3.12500000000000e-01   7.50000000000000e-01

A2s10f =

  -9.68750000000000e-01   9.37500000000000e-01  -6.25000000000000e-01

A2s11f =

   2.48046875000000e-01   3.12500000000000e-01   7.50000000000000e-01

A2s20f =

  -9.68750000000000e-01   9.37500000000000e-01  -6.25000000000000e-01

A2s00f =

   2.48046875000000e-01   3.12500000000000e-01   7.50000000000000e-01

A2s02f =

   9.68750000000000e-01  -9.37500000000000e-01   6.25000000000000e-01

A2s22f =

   2.48046875000000e-01   3.12500000000000e-01   7.50000000000000e-01

ans =

   1.1962e+02   1.2159e+02

ans =

   1.2044e+02   1.1757e+02   1.2153e+02

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

