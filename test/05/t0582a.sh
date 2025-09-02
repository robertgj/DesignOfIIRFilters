#!/bin/sh

prog=schurOneMlatticeFilter_test.m

depends="test/schurOneMlatticeFilter_test.m test_common.m \
schurOneMlatticeFilter.m tf2schurOneMlattice.m schurOneMscale.m \
schurOneMlatticeNoiseGain.m schurOneMlatticeRetimedNoiseGain.m \
KW.m p2n60.m svf.m crossWelch.m \
qroots.oct schurexpand.oct schurdecomp.oct reprand.oct \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct"

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
ngSchur = 0.2500
ngSchurap = 1.0000
ngABCD = 0.2500
ngABCDap = 1.0000
est_varyd = 0.1042
est_varySchurd = 0.1042
varyd = 0.1054
est_varydABCD = 0.1042
varyABCDd = 0.1054
est_varyapd = 0.1667
est_varySchurapd = 0.1667
varyapd = 0.1675
est_varyABCDapd = 0.1667
varyABCDapd = 0.1675
stdxx = 126.21
stdxxf = 126.21
stdxxABCD = 126.22
stdxxABCDf = 126.22
stdxxABCDap = 126.22
stdxxABCDapf = 126.22
At fc Hf=-3.005182 (dB)

Testing Nk=2
ng = 0.5764
ngap = 3.0000
ngSchur = 0.5764
ngSchurap = 3.0000
ngABCD = 0.5000
ngABCDap = 2.0000
est_varyd = 0.1314
est_varySchurd = 0.1314
varyd = 0.1318
est_varydABCD = 0.1250
varyABCDd = 0.1282
est_varyapd = 0.3333
est_varySchurapd = 0.3333
varyapd = 0.3288
est_varyABCDapd = 0.2500
varyABCDapd = 0.2474
stdxx =
   125.70   126.77

stdxxf =
   125.69   126.77

stdxxABCD =
   125.70   126.77

stdxxABCDf =
   125.72   126.78

stdxxABCDap =
   125.70   126.77

stdxxABCDapf =
   125.72   126.78

At fc Hf=-3.000463 (dB)

Testing Nk=3
ng = 0.9823
ngap = 5.0000
ngSchur = 0.9823
ngSchurap = 5.0000
ngABCD = 0.7500
ngABCDap = 3.0000
est_varyd = 0.1652
est_varySchurd = 0.1652
varyd = 0.1667
est_varydABCD = 0.1458
varyABCDd = 0.1477
est_varyapd = 0.5000
est_varySchurapd = 0.5000
varyapd = 0.4977
est_varyABCDapd = 0.3333
varyABCDapd = 0.3377
stdxx =
   125.56   126.17   126.98

stdxxf =
   125.56   126.18   126.99

stdxxABCD =
   125.55   126.17   126.97

stdxxABCDf =
   125.55   126.18   126.98

stdxxABCDap =
   125.55   126.17   126.97

stdxxABCDapf =
   125.55   126.18   126.98

At fc Hf=-2.996263 (dB)

Testing Nk=4
ng = 1.4091
ngap = 7.0000
ngSchur = 1.4091
ngSchurap = 7.0000
ngABCD = 1.0000
ngABCDap = 4.0000
est_varyd = 0.2008
est_varySchurd = 0.2008
varyd = 0.2020
est_varydABCD = 0.1667
varyABCDd = 0.1675
est_varyapd = 0.6667
est_varySchurapd = 0.6667
varyapd = 0.6567
est_varyABCDapd = 0.4167
varyABCDapd = 0.4110
stdxx =
   125.46   125.94   126.28   127.18

stdxxf =
   125.49   125.99   126.33   127.18

stdxxABCD =
   125.46   125.94   126.29   127.17

stdxxABCDf =
   125.48   125.94   126.29   127.16

stdxxABCDap =
   125.46   125.94   126.29   127.17

stdxxABCDapf =
   125.48   125.94   126.29   127.16

At fc Hf=-2.991232 (dB)

Testing Nk=5
ng = 1.8422
ngap = 9.0000
ngSchur = 1.8422
ngSchurap = 9.0000
ngABCD = 1.2500
ngABCDap = 5.0000
est_varyd = 0.2369
est_varySchurd = 0.2369
varyd = 0.2307
est_varydABCD = 0.1875
varyABCDd = 0.1851
est_varyapd = 0.8333
est_varySchurapd = 0.8333
varyapd = 0.8270
est_varyABCDapd = 0.5000
varyABCDapd = 0.4893
stdxx =
   125.35   125.68   125.94   126.51   127.29

stdxxf =
   125.36   125.69   125.96   126.52   127.29

stdxxABCD =
   125.32   125.68   125.94   126.52   127.29

stdxxABCDf =
   125.34   125.69   125.96   126.53   127.29

stdxxABCDap =
   125.32   125.68   125.94   126.52   127.29

stdxxABCDapf =
   125.34   125.69   125.96   126.53   127.29

At fc Hf=-2.979559 (dB)

Testing Nk=6
ng = 2.2767
ngap = 11.000
ngSchur = 2.2767
ngSchurap = 11.000
ngABCD = 1.5000
ngABCDap = 6.0000
est_varyd = 0.2731
est_varySchurd = 0.2731
varyd = 0.2679
est_varydABCD = 0.2083
varyABCDd = 0.2088
est_varyapd = 1.0000
est_varySchurapd = 1.0000
varyapd = 1.0066
est_varyABCDapd = 0.5833
varyABCDapd = 0.5663
stdxx =
   125.18   125.49   125.66   126.41   126.60   127.32

stdxxf =
   125.21   125.48   125.69   126.46   126.61   127.32

stdxxABCD =
   125.18   125.49   125.67   126.41   126.58   127.32

stdxxABCDf =
   125.17   125.48   125.65   126.38   126.56   127.32

stdxxABCDap =
   125.18   125.49   125.67   126.41   126.58   127.32

stdxxABCDapf =
   125.17   125.48   125.65   126.38   126.56   127.32

At fc Hf=-2.998905 (dB)

Testing Nk=7
ng = 2.7104
ngap = 13.000
ngSchur = 2.7104
ngSchurap = 13.000
ngABCD = 1.7500
ngABCDap = 7.0000
est_varyd = 0.3092
est_varySchurd = 0.3092
varyd = 0.3141
est_varydABCD = 0.2292
varyABCDd = 0.2290
est_varyapd = 1.1667
est_varySchurapd = 1.1667
varyapd = 1.1663
est_varyABCDapd = 0.6667
varyABCDapd = 0.6732
stdxx =
   125.16   125.36   125.36   126.23   126.77   126.05   127.63

stdxxf =
   125.16   125.39   125.40   126.28   126.78   126.05   127.63

stdxxABCD =
   125.16   125.35   125.37   126.23   126.77   126.06   127.64

stdxxABCDf =
   125.14   125.33   125.37   126.24   126.77   126.08   127.64

stdxxABCDap =
   125.16   125.35   125.37   126.23   126.77   126.06   127.64

stdxxABCDapf =
   125.14   125.33   125.37   126.24   126.77   126.08   127.64

At fc Hf=-3.020638 (dB)

Testing Nk=8
ng = 3.1421
ngap = 15.000
ngSchur = 3.1421
ngSchurap = 15.000
ngABCD = 2.0000
ngABCDap = 8.0000
est_varyd = 0.3452
est_varySchurd = 0.3452
varyd = 0.3403
est_varydABCD = 0.2500
varyABCDd = 0.2493
est_varyapd = 1.3333
est_varySchurapd = 1.3333
varyapd = 1.3134
est_varyABCDapd = 0.7500
varyABCDapd = 0.7524
stdxx =
   125.04   125.24   125.14   125.97   127.06   125.68   126.61   127.65

stdxxf =
   125.05   125.30   125.18   126.00   127.09   125.69   126.60   127.65

stdxxABCD =
   125.04   125.24   125.13   125.97   127.05   125.69   126.59   127.64

stdxxABCDf =
   125.06   125.24   125.13   126.00   127.06   125.72   126.58   127.64

stdxxABCDap =
   125.04   125.24   125.13   125.97   127.05   125.69   126.59   127.64

stdxxABCDapf =
   125.06   125.24   125.13   126.00   127.06   125.72   126.58   127.64

At fc Hf=-3.060137 (dB)

Testing Nk=9
ng = 3.5711
ngap = 17.000
ngSchur = 3.5711
ngSchurap = 17.000
ngABCD = 2.2500
ngABCDap = 9.0000
est_varyd = 0.3809
est_varySchurd = 0.3809
varyd = 0.3579
est_varydABCD = 0.2708
varyABCDd = 0.2698
est_varyapd = 1.5000
est_varySchurapd = 1.5000
varyapd = 1.4528
est_varyABCDapd = 0.8333
varyABCDapd = 0.8123
stdxx =
 Columns 1 through 8:
   124.99   125.12   124.72   125.59   127.28   125.89   125.98   126.87
 Column 9:
   127.67

stdxxf =
 Columns 1 through 8:
   125.04   125.19   124.75   125.62   127.30   125.87   125.98   126.87
 Column 9:
   127.67

stdxxABCD =
 Columns 1 through 8:
   124.98   125.12   124.72   125.58   127.28   125.88   125.98   126.86
 Column 9:
   127.67

stdxxABCDf =
 Columns 1 through 8:
   124.91   125.06   124.68   125.56   127.32   125.87   125.96   126.86
 Column 9:
   127.67

stdxxABCDap =
 Columns 1 through 8:
   124.98   125.12   124.72   125.58   127.28   125.88   125.98   126.86
 Column 9:
   127.67

stdxxABCDapf =
 Columns 1 through 8:
   124.91   125.06   124.68   125.56   127.32   125.87   125.96   126.86
 Column 9:
   127.67

At fc Hf=-3.088373 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog (mfile)"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
