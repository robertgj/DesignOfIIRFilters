#!/bin/sh

prog=butt3OneMSV_test.m

depends="butt3OneMSV_test.m test_common.m \
schurexpand.oct schurdecomp.oct bin2SD.oct x2nextra.m flt2SD.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m \
schurOneMlattice2Abcd.oct schurOneMlatticeRetimedNoiseGain.m \
schurOneMlatticeFilter.m KW.m optKW.m svf.m crossWelch.m \
p2n60.m qroots.m qzsolve.oct"

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
k =
  -0.9743   0.9292  -0.5321

epsilon =
  -1  -1  -1

p =
   3.0386   0.3466   1.8095

c =
   1.0050e-01   2.9862e-01   1.0166e-02   2.8982e-03

A =
   0.9743   0.2252        0
  -0.2092   0.9054   0.3695
   0.0443  -0.1916   0.4944

B =
        0
        0
   0.8467

C =
   0.305385   0.103493   0.018395

D = 2.8982e-03
Cap =
   0.070452  -0.304829   0.786773

Dap = -0.5321
ng = 0.9823
ngap = 5.0000
ngABCD = 0.7500
ngABCDap = 3.0000
ngDecim = 1.1906
ngDecimap = 5.0000
ngPipe = 0.7500
ngPipeap = 3.0000
ngopt = 0.4705
ngoptap = 3.0000
nbits = 10
scale = 512
ndigits = 3
kf =
  -0.9766   0.9297  -0.5312

cf =
   1.0156e-01   2.9688e-01   9.7656e-03   1.9531e-03

ngf = 1.1019
ngfap = 5
ngABCDf = 0.8472
ngABCDfap = 3.0000
ngPipef = 0.8472
ngPipefap = 3.0000
est_varyd = 0.1752
varyd = 0.1740
est_varyapd = 0.5000
varyapd = 0.4931
stdxxfb =
   137.07   129.01   127.79

est_varyABCDd = 0.1539
varyABCDd = 0.1515
est_varyABCDapd = 0.3333
varyABCDapd = 0.3200
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

