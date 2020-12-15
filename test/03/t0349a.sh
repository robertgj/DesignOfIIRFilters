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
est_varyABCDd = 0.1042
varyABCDd = 0.1049
est_varyABCDapd = 0.1667
varyABCDapd = 0.1673
At fc HABCDf=-3.004614 (dB)

Testing Nk=2
est_varyABCDd = 0.1252
varyABCDd = 0.1244
est_varyABCDapd = 0.2500
varyABCDapd = 0.2422
At fc HABCDf=-2.995112 (dB)

Testing Nk=3
est_varyABCDd = 0.1452
varyABCDd = 0.1460
est_varyABCDapd = 0.3333
varyABCDapd = 0.3312
At fc HABCDf=-3.086457 (dB)

Testing Nk=4
est_varyABCDd = 0.1641
varyABCDd = 0.1626
est_varyABCDapd = 0.4167
varyABCDapd = 0.4285
At fc HABCDf=-2.971763 (dB)

Testing Nk=5
est_varyABCDd = 0.1912
varyABCDd = 0.1840
est_varyABCDapd = 0.5000
varyABCDapd = 0.4899
At fc HABCDf=-2.677854 (dB)

Testing Nk=6
est_varyABCDd = 0.2162
varyABCDd = 0.2173
est_varyABCDapd = 0.5833
varyABCDapd = 0.5881
At fc HABCDf=-2.655840 (dB)

Testing Nk=7
est_varyABCDd = 0.2308
varyABCDd = 0.2343
est_varyABCDapd = 0.6667
varyABCDapd = 0.6789
At fc HABCDf=-3.900121 (dB)

Testing Nk=8
est_varyABCDd = 0.2519
varyABCDd = 0.2468
est_varyABCDapd = 0.7500
varyABCDapd = 0.7286
At fc HABCDf=-3.045956 (dB)

Testing Nk=9
est_varyABCDd = 0.2614
varyABCDd = 0.2657
est_varyABCDapd = 0.8333
varyABCDapd = 0.8707
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

