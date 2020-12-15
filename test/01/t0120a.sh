#!/bin/sh

prog=butt5NSSD_test.m

depends="butt5NSSD_test.m test_common.m \
spectralfactor.oct schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m flt2SD.m x2nextra.m bin2SD.oct schurNSlatticeFilter.m \
crossWelch.m tf2pa.m qroots.m qzsolve.oct"

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
fc = 0.050000
n =
   5.9796e-05   2.9898e-04   5.9796e-04   5.9796e-04   2.9898e-04   5.9796e-05

d =
   1.0000  -3.9845   6.4349  -5.2536   2.1651  -0.3599

Aap1 =
   1.0000  -1.5217   0.6000

Aap2 =
   1.0000  -2.4629   2.0872  -0.5999

S =
   4.5849e-01   9.5463e-02   1.3576e-02   1.8070e-03   5.9796e-05

s10 =
   0.8887   0.9954   0.9999   1.0000   0.3187

s11 =
  -0.9804   0.9787  -0.9581   0.8398  -0.3599

s20 =
   0.1970   0.2051   0.2865   0.5429   0.9330

s00 =
   0.9804  -0.9787   0.9581  -0.8398   0.3599

s02 =
   0.1970   0.2051   0.2865   0.5429   0.9330

s22 =
   2.8187e-01   1.4542e-01   3.0417e-02   4.3262e-03   5.7583e-04   5.9796e-05

c =
   0.0059        0        0        0        0        0
  -0.0292   0.0298        0        0        0        0
   0.1420  -0.2815   0.1451        0        0        0
  -0.4853   1.4373  -1.4577   0.5065        0        0
   0.7835  -3.1485   4.8704  -3.4355   0.9330        0
  -0.3599   2.1651  -5.2536   6.4349  -3.9845   1.0000

nbits = 10
scale = 512
ndigits = 2
A1s10f =
  -0.9375   0.6250

A1s11f =
   0.3125   0.7500

A1s20f =
  -0.9375   0.6250

A1s00f =
   0.3125   0.7500

A1s02f =
   0.9375  -0.6250

A1s22f =
   0.3125   0.7500

A2s10f =
  -0.9688   0.9375  -0.6250

A2s11f =
   0.2480   0.3125   0.7500

A2s20f =
  -0.9688   0.9375  -0.6250

A2s00f =
   0.2480   0.3125   0.7500

A2s02f =
   0.9688  -0.9375   0.6250

A2s22f =
   0.2480   0.3125   0.7500

ans =
   119.62   121.59

ans =
   120.44   117.57   121.53

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

