#!/bin/sh

prog=ellip5OneM_test.m

depends="ellip5OneM_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurOneMscale.m \
tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m schurOneMlattice2Abcd.oct \
schurOneMlatticeFilter.m KW.m bin2SD.oct crossWelch.m"

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
fc =  0.050000
k =
  -0.96570   0.99059  -0.98048   0.96197  -0.69606

epsilon =
   1   1   1   1   1

p =
   0.57978   4.38925   0.30185   3.04067   0.42333

c =
   0.4089832   0.0309038   0.4924523   0.0119256   0.0483754   0.0073597

S =
   0.00137   0.00000   0.00000   0.00000   0.00000   0.00000
  -0.00510   0.00528   0.00000   0.00000   0.00000   0.00000
   0.03819  -0.07412   0.03856   0.00000   0.00000   0.00000
  -0.19229   0.56391  -0.56748   0.19612   0.00000   0.00000
   0.69068  -2.70251   4.05046  -2.75474   0.71799   0.00000
  -0.69606   3.63258  -7.69076   8.26139  -4.50635   1.00000

ng =  2.5504
ngap =  9.0000
est_varyd =  0.29587
varyd =  0.28706
est_varyapd =  0.83333
varyapd =  0.79469
stdxf =
   129.83   128.86   130.16   130.37   128.52

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

