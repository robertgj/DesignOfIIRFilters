#!/bin/sh

prog=butt3OneMSV_test.m

depends="butt3OneMSV_test.m test_common.m \
schurexpand.oct schurdecomp.oct bin2SD.oct x2nextra.m flt2SD.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m \
schurOneMlattice2Abcd.oct schurOneMlatticeRetimedNoiseGain.m \
schurOneMlatticeFilter.m KW.m optKW.m svf.m crossWelch.m"

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
k =
  -0.97432   0.92923  -0.53208

epsilon =
  -1  -1  -1

p =
   3.03862   0.34657   1.80947

c =
   0.1005013   0.2986163   0.0101661   0.0028982

A =
   0.97432   0.22518   0.00000
  -0.20925   0.90536   0.36951
   0.04427  -0.19156   0.49442

B =
   0.00000
   0.00000
   0.84670

C =
   0.305385   0.103493   0.018395

D =  0.0028982
Cap =
   0.070452  -0.304829   0.786773

Dap = -0.53208
ng =  0.98228
ngap =  5.0000
ngABCD =  0.75000
ngABCDap =  3.0000
ngDecim =  1.1906
ngDecimap =  5.0000
ngPipe =  0.75000
ngPipeap =  3.0000
ngopt =  0.47049
ngoptap =  3.0000
nbits =  10
scale =  512
ndigits =  3
kf =
  -0.97656   0.92969  -0.53125

cf =
   0.1015625   0.2968750   0.0097656   0.0019531

ngf =  1.1019
ngfap =  5.0000
ngABCDf =  0.84725
ngABCDfap =  3.0000
ngPipef =  0.84725
ngPipefap =  3.0000
est_varyd =  0.17516
varyd =  0.17410
est_varyapd =  0.50000
varyapd =  0.49283
stdxf =
   137.06   129.04   127.82

est_varyABCDd =  0.15394
varyABCDd =  0.15147
est_varyABCDapd =  0.33333
varyABCDapd =  0.32012
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

