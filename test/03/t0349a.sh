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
k is empty!

Testing Nk=1
est_varyABCDd =    1.0417e-01
varyABCDd =    1.0490e-01
est_varyABCDapd =    1.6667e-01
varyABCDapd =    1.6734e-01
At fc HABCDf=-3.004614 (dB)

Testing Nk=2
est_varyABCDd =    1.2518e-01
varyABCDd =    1.2440e-01
est_varyABCDapd =    2.5000e-01
varyABCDapd =    2.4217e-01
At fc HABCDf=-2.995112 (dB)

Testing Nk=3
est_varyABCDd =    1.4516e-01
varyABCDd =    1.4595e-01
est_varyABCDapd =    3.3333e-01
varyABCDapd =    3.3121e-01
At fc HABCDf=-3.086457 (dB)

Testing Nk=4
est_varyABCDd =    1.6408e-01
varyABCDd =    1.6263e-01
est_varyABCDapd =    4.1667e-01
varyABCDapd =    4.2845e-01
At fc HABCDf=-2.971763 (dB)

Testing Nk=5
est_varyABCDd =    1.9124e-01
varyABCDd =    1.8404e-01
est_varyABCDapd =    5.0000e-01
varyABCDapd =    4.8990e-01
At fc HABCDf=-2.677854 (dB)

Testing Nk=6
est_varyABCDd =    2.1622e-01
varyABCDd =    2.1729e-01
est_varyABCDapd =    5.8333e-01
varyABCDapd =    5.8813e-01
At fc HABCDf=-2.655840 (dB)

Testing Nk=7
est_varyABCDd =    2.3080e-01
varyABCDd =    2.3430e-01
est_varyABCDapd =    6.6667e-01
varyABCDapd =    6.7891e-01
At fc HABCDf=-3.900121 (dB)

Testing Nk=8
est_varyABCDd =    2.5189e-01
varyABCDd =    2.4683e-01
est_varyABCDapd =    7.5000e-01
varyABCDapd =    7.2857e-01
At fc HABCDf=-3.045956 (dB)

Testing Nk=9
est_varyABCDd =    2.6143e-01
varyABCDd =    2.6566e-01
est_varyABCDapd =    8.3333e-01
varyABCDapd =    8.7073e-01
At fc HABCDf=-2.722792 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings.
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

