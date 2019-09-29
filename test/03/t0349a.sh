#!/bin/sh

prog=schurOneMlatticeRetimed2Abcd_test.m
depends="schurOneMlatticeRetimed2Abcd_test.m test_common.m \
schurOneMlatticeRetimed2Abcd.m schurOneMlatticeRetimedNoiseGain.m \
tf2schurOneMlattice.m Abcd2tf.m schurOneMscale.m KW.m svf.m crossWelch.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct reprand.oct"

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
k is empty!

Testing Nk=1
est_varyABCDd =  0.10417
varyABCDd =  0.10490
est_varyABCDapd =  0.16667
varyABCDapd =  0.16734
At fc HABCDf=-3.004614 (dB)

Testing Nk=2
est_varyABCDd =  0.12518
varyABCDd =  0.12440
est_varyABCDapd =  0.25000
varyABCDapd =  0.24217
At fc HABCDf=-2.995112 (dB)

Testing Nk=3
est_varyABCDd =  0.14516
varyABCDd =  0.14595
est_varyABCDapd =  0.33333
varyABCDapd =  0.33121
At fc HABCDf=-3.086457 (dB)

Testing Nk=4
est_varyABCDd =  0.16408
varyABCDd =  0.16263
est_varyABCDapd =  0.41667
varyABCDapd =  0.42845
At fc HABCDf=-2.971763 (dB)

Testing Nk=5
est_varyABCDd =  0.19124
varyABCDd =  0.18404
est_varyABCDapd =  0.50000
varyABCDapd =  0.48990
At fc HABCDf=-2.677854 (dB)

Testing Nk=6
est_varyABCDd =  0.21622
varyABCDd =  0.21729
est_varyABCDapd =  0.58333
varyABCDapd =  0.58813
At fc HABCDf=-2.655840 (dB)

Testing Nk=7
est_varyABCDd =  0.23080
varyABCDd =  0.23430
est_varyABCDapd =  0.66667
varyABCDapd =  0.67891
At fc HABCDf=-3.900121 (dB)

Testing Nk=8
est_varyABCDd =  0.25189
varyABCDd =  0.24683
est_varyABCDapd =  0.75000
varyABCDapd =  0.72857
At fc HABCDf=-3.045956 (dB)

Testing Nk=9
est_varyABCDd =  0.26143
varyABCDd =  0.26566
est_varyABCDapd =  0.83333
varyABCDapd =  0.87073
At fc HABCDf=-2.722792 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. .
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

