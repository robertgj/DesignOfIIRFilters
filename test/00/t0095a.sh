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
fc =  0.050000
n =
   0.0028982   0.0086946   0.0086946   0.0028982

d =
   1.00000  -2.37409   1.92936  -0.53208

s10 =
   0.3209629   0.0569565   0.0028982

s11 =
   0.94709   0.99838   0.32297

s20 =
  -0.97432   0.92923  -0.53208

s00 =
   0.22518   0.36951   0.84670

s02 =
   0.97432  -0.92923   0.53208

s22 =
   0.22518   0.36951   0.84670

ng =  1.1906
ngap =  5.0000
nbits =  10
scale =  512
ndigits =  2
s10f =
   0.3125000   0.0546875   0.0019531

s11f =
   0.93750   0.99805   0.31250

s20f =
  -0.96875   0.93750  -0.53125

s00f =
   0.21875   0.37500   0.87500

s02f =
   0.96875  -0.93750   0.53125

s22f =
   0.21875   0.37500   0.87500

ngf =  1.1334
ngfap =  5.6989
est_varyd =  0.17778
varyd =  0.17627
est_varyapd =  0.55824
varyapd =  0.55307
stdxf =
   134.21   135.04   132.49

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

