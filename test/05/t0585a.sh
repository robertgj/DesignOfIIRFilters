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
varyd = 0.1221
est_varyapd = 0.2500
varyapd = 0.2408
stdxx =
   127.48   127.47   128.47

stdxxf =
   127.48   127.47   128.48

At fc Hf=-3.024494 (dB)

Testing Nk=3
ng = 0.7500
ngap = 3.0000
est_varyd = 0.1458
varyd = 0.1457
est_varyapd = 0.3333
varyapd = 0.3267
stdxx =
   127.51   127.50   127.45   127.55

stdxxf =
   127.51   127.51   127.45   127.55

At fc Hf=-3.023339 (dB)

Testing Nk=4
ng = 1.0000
ngap = 4.0000
est_varyd = 0.1667
varyd = 0.1619
est_varyapd = 0.4167
varyapd = 0.4073
stdxx =
   126.16   126.30   127.89   127.07   126.09   128.05

stdxxf =
   126.17   126.31   127.89   127.08   126.10   128.05

At fc Hf=-3.023029 (dB)

Testing Nk=5
ng = 1.2500
ngap = 5.0000
est_varyd = 0.1875
varyd = 0.1901
est_varyapd = 0.5000
varyapd = 0.4992
stdxx =
   128.07   128.28   129.69   128.51   127.99   126.76   128.34

stdxxf =
   128.06   128.26   129.66   128.51   127.98   126.76   128.34

At fc Hf=-3.187397 (dB)

Testing Nk=6
ng = 1.5000
ngap = 6.0000
est_varyd = 0.2083
varyd = 0.1984
est_varyapd = 0.5833
varyapd = 0.5949
stdxx =
 Columns 1 through 8:
   125.49   125.12   123.59   124.26   125.60   126.84   126.74   125.60
 Column 9:
   127.97

stdxxf =
 Columns 1 through 8:
   125.47   125.10   123.53   124.21   125.58   126.83   126.73   125.58
 Column 9:
   127.96

At fc Hf=-3.037355 (dB)

Testing Nk=7
ng = 1.7500
ngap = 7.0000
est_varyd = 0.2292
varyd = 0.2289
est_varyapd = 0.6667
varyapd = 0.6272
stdxx =
 Columns 1 through 8:
   128.46   129.20   131.23   127.11   128.31   128.31   129.87   128.28
 Columns 9 and 10:
   128.85   128.24

stdxxf =
 Columns 1 through 8:
   128.52   129.24   131.27   127.11   128.35   128.34   129.88   128.33
 Columns 9 and 10:
   128.86   128.24

At fc Hf=-2.928875 (dB)

Testing Nk=8
ng = 2.0000
ngap = 8.0000
est_varyd = 0.2500
varyd = 0.2260
est_varyapd = 0.7500
varyapd = 0.7285
stdxx =
 Columns 1 through 8:
   129.79   130.14   130.90   127.39   129.71   129.89   130.42   129.69
 Columns 9 through 12:
   128.11   128.78   129.70   128.21

stdxxf =
 Columns 1 through 8:
   129.77   130.12   130.89   127.39   129.69   129.91   130.43   129.67
 Columns 9 through 12:
   128.10   128.78   129.68   128.21

At fc Hf=-2.962401 (dB)

Testing Nk=9
ng = 2.2500
ngap = 9.0000
est_varyd = 0.2708
varyd = 0.2586
est_varyapd = 0.8333
varyapd = 0.8443
stdxx =
 Columns 1 through 8:
   127.31   127.65   128.13   126.42   127.29   127.98   126.64   127.26
 Columns 9 through 13:
   126.81   128.43   127.25   128.84   128.01

stdxxf =
 Columns 1 through 8:
   127.33   127.67   128.16   126.42   127.30   127.98   126.68   127.26
 Columns 9 through 13:
   126.80   128.45   127.26   128.84   128.01

At fc Hf=-3.154902 (dB)
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
