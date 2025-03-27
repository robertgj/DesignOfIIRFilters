#!/bin/sh

prog=schurOneMlatticePipelinedFilter_test.m

depends="test/schurOneMlatticePipelinedFilter_test.m test_common.m \
schurOneMlatticePipelinedFilter.m schurOneMscale.m Abcd2ng.m \
schurOneMlatticePipelined2Abcd.m KW.m p2n60.m svf.m crossWelch.m \
tf2schurOneMlattice.m tf2schurOneMlatticePipelined.m \
qroots.oct schurexpand.oct schurdecomp.oct reprand.oct \
complex_zhong_inverse.oct"

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

Testing Nk=1
ng = 0.2500
ngap = 1.0000
est_varyd = 0.1042
varyd = 0.1054
est_varyapd = 0.1667
varyapd = 0.1675
stdxx = 126.21
stdxxf = 126.21
At fc Hf=-3.005182 (dB)

Testing Nk=2
ng = 0.5000
ngap = 2.0000
est_varyd = 0.1250
varyd = 0.1271
est_varyapd = 0.2500
varyapd = 0.2507
stdxx =
   125.70   125.69   126.76

stdxxf =
   125.70   125.69   126.76

At fc Hf=-2.996857 (dB)

Testing Nk=3
ng = 0.7500
ngap = 3.0000
est_varyd = 0.1458
varyd = 0.1472
est_varyapd = 0.3333
varyapd = 0.3310
stdxx =
   125.55   125.57   126.17   126.98

stdxxf =
   125.55   125.57   126.16   126.98

At fc Hf=-2.992523 (dB)

Testing Nk=4
ng = 1.0000
ngap = 4.0000
est_varyd = 0.1667
varyd = 0.1648
est_varyapd = 0.4167
varyapd = 0.4235
stdxx =
   125.46   125.50   125.94   126.29   125.44   127.17

stdxxf =
   125.48   125.51   125.94   126.30   125.46   127.17

At fc Hf=-2.961078 (dB)

Testing Nk=5
ng = 1.2500
ngap = 5.0000
est_varyd = 0.1875
varyd = 0.1861
est_varyapd = 0.5000
varyapd = 0.4965
stdxx =
   125.30   125.31   125.71   125.94   125.27   126.53   127.29

stdxxf =
   125.28   125.29   125.67   125.94   125.25   126.55   127.28

At fc Hf=-2.992423 (dB)

Testing Nk=6
ng = 1.5000
ngap = 6.0000
est_varyd = 0.2083
varyd = 0.2036
est_varyapd = 0.5833
varyapd = 0.5655
stdxx =
 Columns 1 through 8:
   125.19   125.26   125.49   125.67   125.18   126.40   126.58   125.18
 Column 9:
   127.33

stdxxf =
 Columns 1 through 8:
   125.19   125.26   125.50   125.68   125.18   126.41   126.59   125.17
 Column 9:
   127.33

At fc Hf=-3.007679 (dB)

Testing Nk=7
ng = 1.7500
ngap = 7.0000
est_varyd = 0.2292
varyd = 0.2257
est_varyapd = 0.6667
varyapd = 0.6483
stdxx =
 Columns 1 through 8:
   125.15   125.19   125.35   125.38   125.12   126.23   126.77   125.13
 Columns 9 and 10:
   126.05   127.63

stdxxf =
 Columns 1 through 8:
   125.16   125.18   125.35   125.38   125.12   126.20   126.78   125.13
 Columns 9 and 10:
   126.05   127.63

At fc Hf=-3.004332 (dB)

Testing Nk=8
ng = 2.0000
ngap = 8.0000
est_varyd = 0.2500
varyd = 0.2417
est_varyapd = 0.7500
varyapd = 0.7301
stdxx =
 Columns 1 through 8:
   125.05   125.11   125.24   125.08   125.03   125.99   127.05   125.03
 Columns 9 through 12:
   125.71   126.59   125.03   127.68

stdxxf =
 Columns 1 through 8:
   125.05   125.14   125.29   125.11   125.04   126.01   127.02   125.04
 Columns 9 through 12:
   125.73   126.59   125.04   127.68

At fc Hf=-3.023921 (dB)

Testing Nk=9
ng = 2.2500
ngap = 9.0000
est_varyd = 0.2708
varyd = 0.2623
est_varyapd = 0.8333
varyapd = 0.8644
stdxx =
 Columns 1 through 8:
   124.94   125.00   125.13   124.70   124.93   125.60   127.28   124.93
 Columns 9 through 13:
   125.91   125.98   124.93   126.90   127.67

stdxxf =
 Columns 1 through 8:
   124.90   124.97   125.10   124.69   124.90   125.55   127.29   124.90
 Columns 9 through 13:
   125.87   125.98   124.91   126.87   127.67

At fc Hf=-3.105181 (dB)
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
