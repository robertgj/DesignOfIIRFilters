#!/bin/sh

prog=butt3NSSV_test.m

depends="butt3NSSV_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m \
schurNSlatticeRetimedNoiseGain.m \
schurNSlatticeFilter.m KW.m flt2SD.m x2nextra.m bin2SD.oct crossWelch.m"

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
   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =
   1.0000  -2.3741   1.9294  -0.5321

s10 =
   3.2096e-01   5.6957e-02   2.8982e-03

s11 =
   0.9471   0.9984   0.3230

s20 =
  -0.9743   0.9292  -0.5321

s00 =
   0.2252   0.3695   0.8467

s02 =
   0.9743  -0.9292   0.5321

s22 =
   0.2252   0.3695   0.8467

ng = 1.1906
ngap = 5.0000
nbits = 10
scale = 512
ndigits = 2
s10f =
   3.1250e-01   5.4688e-02   1.9531e-03

s11f =
   0.9375   0.9980   0.3125

s20f =
  -0.9688   0.9375  -0.5312

s00f =
   0.2188   0.3750   0.8750

s02f =
   0.9688  -0.9375   0.5312

s22f =
   0.2188   0.3750   0.8750

ngf = 1.1334
ngfap = 5.6989
est_varyd = 0.1778
varyd = 0.1763
est_varyapd = 0.5582
varyapd = 0.5531
stdxf =
   134.21   135.04   132.49

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

