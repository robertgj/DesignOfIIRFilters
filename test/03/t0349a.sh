#!/bin/sh

prog=schurOneMlatticeRetimed2Abcd_test.m
depends="schurOneMlatticeRetimed2Abcd_test.m test_common.m \
schurOneMlatticeRetimed2Abcd.m schurOneMlatticeRetimedNoiseGain.m \
tf2schurOneMlattice.m Abcd2tf.m schurOneMscale.m KW.m svf.m crossWelch.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct reprand.oct \
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
k is empty!

Testing Nk=1
est_varyABCDd = 0.1042
varyABCDd = 0.1051
est_varyABCDapd = 0.1667
varyABCDapd = 0.1672
At fc HABCDf=-3.004255 (dB)

Testing Nk=2
est_varyABCDd = 0.1252
varyABCDd = 0.1245
est_varyABCDapd = 0.2500
varyABCDapd = 0.2424
At fc HABCDf=-2.993889 (dB)

Testing Nk=3
est_varyABCDd = 0.1452
varyABCDd = 0.1449
est_varyABCDapd = 0.3333
varyABCDapd = 0.3282
At fc HABCDf=-3.091620 (dB)

Testing Nk=4
est_varyABCDd = 0.1641
varyABCDd = 0.1655
est_varyABCDapd = 0.4167
varyABCDapd = 0.4321
At fc HABCDf=-2.972504 (dB)

Testing Nk=5
est_varyABCDd = 0.1912
varyABCDd = 0.1824
est_varyABCDapd = 0.5000
varyABCDapd = 0.4853
At fc HABCDf=-2.699736 (dB)

Testing Nk=6
est_varyABCDd = 0.2162
varyABCDd = 0.2157
est_varyABCDapd = 0.5833
varyABCDapd = 0.5668
At fc HABCDf=-2.689483 (dB)

Testing Nk=7
est_varyABCDd = 0.2308
varyABCDd = 0.2307
est_varyABCDapd = 0.6667
varyABCDapd = 0.6663
At fc HABCDf=-3.932636 (dB)

Testing Nk=8
est_varyABCDd = 0.2519
varyABCDd = 0.2433
est_varyABCDapd = 0.7500
varyABCDapd = 0.7422
At fc HABCDf=-3.127983 (dB)

Testing Nk=9
est_varyABCDd = 0.2614
varyABCDd = 0.2586
est_varyABCDapd = 0.8333
varyABCDapd = 0.8338
At fc HABCDf=-2.872727 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. .
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

