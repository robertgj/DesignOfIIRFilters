#!/bin/sh

prog=schurOneMlatticeFilter_test.m

depends="test/schurOneMlatticeFilter_test.m test_common.m \
tf2schurOneMlattice.m schurOneMscale.m \
schurOneMlatticeNoiseGain.m schurOneMlatticeRetimedNoiseGain.m \
KW.m p2n60.m svf.m crossWelch.m tf2Abcd.m print_polynomial.m \
schurOneMlatticeFilter.oct schurOneMlattice2Abcd.oct \
schurexpand.oct schurdecomp.oct \
reprand.oct qroots.oct complex_zhong_inverse.oct"

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
# the output should look like this (as for m-file test in t0582a.sh)
#
cat > test.ok << 'EOF'

Testing Nk=1
ngABCDds = 0.2500
ng = 0.2500
ngap = 1.0000
ngSchur = 0.2500
ngSchurap = 1
ngABCD = 0.2500
ngABCDap = 1
pow2pd = 1
ng2 = 0.1751
ng2ap = 0.7003
ngABCD2 = 0.2500
ngABCD2ap = 1.0000
pow2paltd = 1
ng2alt = 0.1751
ng2altap = 0.7003
ngABCD2alt = 0.2500
ngABCD2altap = 1.0000
ng2sv = 0.2500
ng2svap = 1.0000
ng2svalt = 0.2500
ng2svaltap = 1.0000
est_varyd = 0.1042
est_varySchurd = 0.1042
varyd = 0.1051
est_vary2d = 0.097923
vary2d = 0.098252
est_vary2altd = 0.097923
vary2altd = 0.098252
est_vary2svd = 0.1042
vary2svd = 0.098252
est_vary2svaltd = 0.1042
vary2svaltd = 0.098252
est_varyABCDd = 0.1042
varyABCDd = 0.1051
est_varyABCDdsd = 0.1042
varyABCDdsd = 0.1051
est_varyapd = 0.1667
est_varySchurapd = 0.1667
varyapd = 0.1659
est_vary2apd = 0.1417
vary2apd = 0.1415
est_vary2altapd = 0.1417
vary2altapd = 0.1415
est_varyABCDapd = 0.1667
varyABCDapd = 0.1659
std_xx = 128.14
std_xxf = 128.14
std_xx2 = 153.12
std_xx2f = 153.12
std_xx2alt = 153.12
std_xx2altf = 153.12
std_xx2sv = 153.12
std_xx2svf = 153.12
std_xx2svalt = 153.12
std_xx2svaltf = 153.12
std_xxABCD = 128.14
std_xxABCDf = 128.13
std_xxABCDds = 128.14
std_xxABCDdsf = 128.13
max_std_xx = 128.14
max_std_xxf = 128.14
max_std_xx2 = 153.12
max_std_xx2f = 153.12
max_std_xx2alt = 153.12
max_std_xx2altf = 153.12
max_std_xx2sv = 153.12
max_std_xx2svf = 153.12
max_std_xx2svalt = 153.12
max_std_xx2svaltf = 153.12
max_std_xxABCD = 128.14
max_std_xxABCDf = 128.13
max_std_xxABCDds = 128.14
max_std_xxABCDdsf = 128.13
max_xx = 260.68
max_xxf = 261
max_xx2 = 311.50
max_xx2f = 311
max_xx2alt = 311.50
max_xx2altf = 311
max_xx2sv = 311.50
max_xx2svf = 311
max_xx2alt = 311.50
max_xx2altf = 311
max_xxABCD = 260.68
max_xxABCDf = 261
max_xxABCDds = 260.68
max_xxABCDdsf = 261
At fap Hf=-1.0022 (dB)

Testing Nk=2
ngABCDds = 0.5451
ng = 0.6079
ngap = 3
ngSchur = 0.6079
ngSchurap = 3.0000
ngABCD = 0.5597
ngABCDap = 2.0000
pow2pd =
   1   1

ng2 = 0.3486
ng2ap = 1.8562
ngABCD2 = 0.5597
ngABCD2ap = 2.0000
pow2paltd =
   1   1

ng2alt = 0.3486
ng2altap = 1.8562
ngABCD2alt = 0.5597
ngABCD2altap = 2.0000
ng2sv = 0.5597
ng2svap = 2
ng2svalt = 0.5597
ng2svaltap = 2
est_varyd = 0.1340
est_varySchurd = 0.1340
varyd = 0.1328
est_vary2d = 0.1124
vary2d = 0.1059
est_vary2altd = 0.1124
vary2altd = 0.1059
est_vary2svd = 0.1300
vary2svd = 0.1084
est_vary2svaltd = 0.1300
vary2svaltd = 0.1084
est_varyABCDd = 0.1300
varyABCDd = 0.1289
est_varyABCDdsd = 0.1288
varyABCDdsd = 0.1227
est_varyapd = 0.3333
est_varySchurapd = 0.3333
varyapd = 0.3314
est_vary2apd = 0.2380
vary2apd = 0.2305
est_vary2altapd = 0.2380
vary2altapd = 0.2305
est_varyABCDapd = 0.2500
varyABCDapd = 0.2520
std_xx =
   128.10   128.02

std_xxf =
   128.10   128.02

std_xx2 =
   138.51   180.99

std_xx2f =
   138.55   181.04

std_xx2alt =
   138.51   180.99

std_xx2altf =
   138.55   181.04

std_xx2sv =
   138.50   180.98

std_xx2svf =
   138.51   180.99

std_xx2svalt =
   138.50   180.98

std_xx2svaltf =
   138.51   180.99

std_xxABCD =
   128.10   128.02

std_xxABCDf =
   128.10   128.02

std_xxABCDds =
   128.10   128.10

std_xxABCDdsf =
   128.10   128.10

max_std_xx = 128.10
max_std_xxf = 128.10
max_std_xx2 = 180.99
max_std_xx2f = 181.04
max_std_xx2alt = 180.99
max_std_xx2altf = 181.04
max_std_xx2sv = 180.98
max_std_xx2svf = 180.99
max_std_xx2svalt = 180.98
max_std_xx2svaltf = 180.99
max_std_xxABCD = 128.10
max_std_xxABCDf = 128.10
max_std_xxABCDds = 128.10
max_std_xxABCDdsf = 128.10
max_xx = 345.41
max_xxf = 345
max_xx2 = 448.53
max_xx2f = 449
max_xx2alt = 448.53
max_xx2altf = 449
max_xx2sv = 448.53
max_xx2svf = 449
max_xx2alt = 448.53
max_xx2altf = 449
max_xxABCD = 345.41
max_xxABCDf = 345
max_xxABCDds = 345.41
max_xxABCDdsf = 345
At fap Hf=-0.9919 (dB)

Testing Nk=3
ngABCDds = 1.4269
ng = 1.0494
ngap = 5.0000
ngSchur = 1.0494
ngSchurap = 5.0000
ngABCD = 0.9011
ngABCDap = 3.0000
pow2pd =
   0.5000   1.0000   0.5000

ng2 = 0.4237
ng2ap = 1.9400
ngABCD2 = 0.9011
ngABCD2ap = 3.0000
pow2paltd =
   1   2   1

ng2alt = 1.6948
ng2altap = 7.7600
ngABCD2alt = 0.9011
ngABCD2altap = 3.0000
ng2sv = 0.9011
ng2svap = 3.0000
ng2svalt = 0.9011
ng2svaltap = 3.0000
est_varyd = 0.1708
est_varySchurd = 0.1708
varyd = 0.1698
est_vary2d = 0.1186
vary2d = 0.1164
est_vary2altd = 0.2246
vary2altd = 0.2226
est_vary2svd = 0.1584
vary2svd = 0.1129
est_vary2svaltd = 0.1584
vary2svaltd = 0.2052
est_varyABCDd = 0.1584
varyABCDd = 0.1589
est_varyABCDdsd = 0.2022
varyABCDdsd = 0.1607
est_varyapd = 0.5000
est_varySchurapd = 0.5000
varyapd = 0.4980
est_vary2apd = 0.2450
vary2apd = 0.2426
est_vary2altapd = 0.7300
vary2altapd = 0.7461
est_varyABCDapd = 0.3333
varyABCDapd = 0.3336
std_xx =
   128.34   128.27   128.10

std_xxf =
   128.35   128.28   128.10

std_xx2 =
   250.44   206.74   190.18

std_xx2f =
   250.44   206.74   190.19

std_xx2alt =
   125.220   103.368    95.089

std_xx2altf =
   125.216   103.365    95.098

std_xx2sv =
   250.43   206.74   190.18

std_xx2svf =
   250.43   206.73   190.18

std_xx2svalt =
   125.214   103.368    95.089

std_xx2svaltf =
   125.221   103.373    95.090

std_xxABCD =
   128.34   128.27   128.10

std_xxABCDf =
   128.34   128.28   128.10

std_xxABCDds =
   128.34   128.34   128.34

std_xxABCDdsf =
   128.34   128.34   128.34

max_std_xx = 128.34
max_std_xxf = 128.35
max_std_xx2 = 250.44
max_std_xx2f = 250.44
max_std_xx2alt = 125.22
max_std_xx2altf = 125.22
max_std_xx2sv = 250.43
max_std_xx2svf = 250.43
max_std_xx2svalt = 125.21
max_std_xx2svaltf = 125.22
max_std_xxABCD = 128.34
max_std_xxABCDf = 128.34
max_std_xxABCDds = 128.34
max_std_xxABCDdsf = 128.34
max_xx = 436.18
max_xxf = 435
max_xx2 = 851.13
max_xx2f = 850
max_xx2alt = 425.56
max_xx2altf = 427
max_xx2sv = 851.13
max_xx2svf = 851
max_xx2alt = 425.56
max_xx2altf = 427
max_xxABCD = 436.18
max_xxABCDf = 436
max_xxABCDds = 436.18
max_xxABCDdsf = 436
At fap Hf=-1.0193 (dB)

Testing Nk=4
ngABCDds = 7.3039
ng = 1.5161
ngap = 7.0000
ngSchur = 1.5161
ngSchurap = 7.0000
ngABCD = 1.2514
ngABCDap = 4.0000
pow2pd =
   0.5000   1.0000   0.2500   0.5000

ng2 = 0.7685
ng2ap = 3.5298
ngABCD2 = 1.2514
ngABCD2ap = 4.0000
pow2paltd =
   1.0000   1.0000   0.5000   1.0000

ng2alt = 2.2235
ng2altap = 10.321
ngABCD2alt = 1.2514
ngABCD2altap = 4.0000
ng2sv = 1.2514
ng2svap = 4.0000
ng2svalt = 1.2514
ng2svaltap = 4.0000
est_varyd = 0.2097
est_varySchurd = 0.2097
varyd = 0.2077
est_vary2d = 0.1474
vary2d = 0.1476
est_vary2altd = 0.2686
vary2altd = 0.2679
est_vary2svd = 0.1876
vary2svd = 0.1344
est_vary2svaltd = 0.1876
vary2svaltd = 0.2446
est_varyABCDd = 0.1876
varyABCDd = 0.1876
est_varyABCDdsd = 0.6920
varyABCDdsd = 0.2903
est_varyapd = 0.6667
est_varySchurapd = 0.6667
varyapd = 0.6613
est_vary2apd = 0.3775
vary2apd = 0.3799
est_vary2altapd = 0.9434
vary2altapd = 0.9444
est_varyABCDapd = 0.4167
varyABCDapd = 0.4128
std_xx =
   127.64   127.68   128.37   128.07

std_xxf =
   127.65   127.69   128.37   128.07

std_xx2 =
   194.27   160.47   194.29   184.96

std_xx2f =
   194.26   160.46   194.29   184.96

std_xx2alt =
    97.133   160.468    97.143    92.478

std_xx2altf =
    97.141   160.481    97.148    92.480

std_xx2sv =
   194.27   160.47   194.29   184.95

std_xx2svf =
   194.27   160.47   194.29   184.95

std_xx2svalt =
    97.133   160.467    97.143    92.477

std_xx2svaltf =
    97.146   160.491    97.150    92.478

std_xxABCD =
   127.64   127.68   128.37   128.07

std_xxABCDf =
   127.65   127.68   128.37   128.07

std_xxABCDds =
   127.64   127.64   127.64   127.64

std_xxABCDdsf =
   127.64   127.64   127.64   127.64

max_std_xx = 128.37
max_std_xxf = 128.37
max_std_xx2 = 194.29
max_std_xx2f = 194.29
max_std_xx2alt = 160.47
max_std_xx2altf = 160.48
max_std_xx2sv = 194.29
max_std_xx2svf = 194.29
max_std_xx2svalt = 160.47
max_std_xx2svaltf = 160.49
max_std_xxABCD = 128.37
max_std_xxABCDf = 128.37
max_std_xxABCDds = 127.64
max_std_xxABCDdsf = 127.64
max_xx = 494.47
max_xxf = 495
max_xx2 = 716.13
max_xx2f = 716
max_xx2alt = 621.46
max_xx2altf = 622
max_xx2sv = 716.13
max_xx2svf = 715
max_xx2alt = 621.46
max_xx2altf = 622
max_xxABCD = 494.47
max_xxABCDf = 494
max_xxABCDds = 470.52
max_xxABCDdsf = 471
At fap Hf=-1.0121 (dB)

Testing Nk=5
ngABCDds = 73.847
ng = 2.0014
ngap = 9.0000
ngSchur = 2.0014
ngSchurap = 9.0000
ngABCD = 1.6039
ngABCDap = 5.0000
pow2pd =
   1.0000   1.0000   0.2500   0.5000   1.0000

ng2 = 1.1441
ng2ap = 5.1784
ngABCD2 = 1.6039
ngABCD2ap = 5.0000
pow2paltd =
   1.0000   2.0000   0.2500   0.5000   1.0000

ng2alt = 1.6220
ng2altap = 7.4113
ngABCD2alt = 1.6039
ngABCD2altap = 5.0000
ng2sv = 1.6039
ng2svap = 5.0000
ng2svalt = 1.6039
ng2svaltap = 5.0000
est_varyd = 0.2501
est_varySchurd = 0.2501
varyd = 0.2514
est_vary2d = 0.1787
vary2d = 0.1813
est_vary2altd = 0.2185
vary2altd = 0.2229
est_vary2svd = 0.2170
vary2svd = 0.1633
est_vary2svaltd = 0.2170
vary2svaltd = 0.1845
est_varyABCDd = 0.2170
varyABCDd = 0.2192
est_varyABCDdsd = 6.2372
varyABCDdsd = 1.0043
est_varyapd = 0.8333
est_varySchurapd = 0.8333
varyapd = 0.8389
est_vary2apd = 0.5149
vary2apd = 0.5091
est_vary2altapd = 0.7009
vary2altapd = 0.6902
est_varyABCDapd = 0.5000
varyABCDapd = 0.4968
std_xx =
   127.13   127.08   128.27   128.13   128.04

std_xxf =
   127.14   127.09   128.27   128.13   128.04

std_xx2 =
   136.92   208.31   154.16   169.80   176.84

std_xx2f =
   136.92   208.32   154.16   169.80   176.84

std_xx2alt =
   136.92   104.16   154.16   169.80   176.84

std_xx2altf =
   136.92   104.16   154.16   169.79   176.84

std_xx2sv =
   136.92   208.31   154.16   169.80   176.84

std_xx2svf =
   136.94   208.34   154.16   169.80   176.84

std_xx2svalt =
   136.92   104.16   154.16   169.80   176.84

std_xx2svaltf =
   136.94   104.17   154.16   169.80   176.84

std_xxABCD =
   127.13   127.08   128.27   128.13   128.04

std_xxABCDf =
   127.15   127.09   128.27   128.14   128.04

std_xxABCDds =
   127.13   127.13   127.13   127.13   127.13

std_xxABCDdsf =
   127.14   127.14   127.14   127.14   127.14

max_std_xx = 128.27
max_std_xxf = 128.27
max_std_xx2 = 208.31
max_std_xx2f = 208.32
max_std_xx2alt = 176.84
max_std_xx2altf = 176.84
max_std_xx2sv = 208.31
max_std_xx2svf = 208.34
max_std_xx2svalt = 176.84
max_std_xx2svaltf = 176.84
max_std_xxABCD = 128.27
max_std_xxABCDf = 128.27
max_std_xxABCDds = 127.13
max_std_xxABCDdsf = 127.14
max_xx = 516.56
max_xxf = 515
max_xx2 = 809.20
max_xx2f = 812
max_xx2alt = 606.13
max_xx2altf = 606
max_xx2sv = 809.20
max_xx2svf = 810
max_xx2alt = 606.13
max_xx2altf = 606
max_xxABCD = 516.56
max_xxABCDf = 518
max_xxABCDds = 516.56
max_xxABCDdsf = 520
At fap Hf=-1.0709 (dB)

Testing Nk=6
ngABCDds = 1500.1
ng = 2.5861
ngap = 11.000
ngSchur = 2.5861
ngSchurap = 11.000
ngABCD = 1.9569
ngABCDap = 6.0000
pow2pd =
   1.0000   2.0000   0.1250   0.2500   1.0000   0.5000

ng2 = 1.0896
ng2ap = 4.5244
ngABCD2 = 1.9569
ngABCD2ap = 6.0000
pow2paltd =
   2.0000   2.0000   0.2500   0.5000   2.0000   1.0000

ng2alt = 3.4229
ng2altap = 14.554
ngABCD2alt = 1.9569
ngABCD2altap = 6.0000
ng2sv = 1.9569
ng2svap = 6.0000
ng2svalt = 1.9569
ng2svaltap = 6.0000
est_varyd = 0.2988
est_varySchurd = 0.2988
varyd = 0.2988
est_vary2d = 0.1741
vary2d = 0.1752
est_vary2altd = 0.3686
vary2altd = 0.3686
est_vary2svd = 0.2464
vary2svd = 0.1509
est_vary2svaltd = 0.2464
vary2svaltd = 0.3133
est_varyABCDd = 0.2464
varyABCDd = 0.2434
est_varyABCDdsd = 125.09
varyABCDdsd = 7.6089
est_varyapd = 1.0000
est_varySchurapd = 1.0000
varyapd = 1.0082
est_vary2apd = 0.4604
vary2apd = 0.4620
est_vary2altapd = 1.2962
vary2altapd = 1.3181
est_varyABCDapd = 0.5833
varyABCDapd = 0.5838
std_xx =
   131.17   131.21   128.90   129.02   128.01   128.22

std_xxf =
   131.15   131.19   128.89   129.00   128.01   128.22

std_xx2 =
   237.82   170.74   247.07   247.43   182.70   184.21

std_xx2f =
   237.79   170.72   247.07   247.43   182.70   184.20

std_xx2alt =
   118.909   170.742   123.534   123.715    91.350    92.103

std_xx2altf =
   118.886   170.710   123.508   123.685    91.339    92.100

std_xx2sv =
   237.82   170.74   247.07   247.43   182.70   184.21

std_xx2svf =
   237.77   170.71   247.07   247.43   182.70   184.21

std_xx2svalt =
   118.908   170.743   123.535   123.717    91.350    92.105

std_xx2svaltf =
   118.950   170.806   123.548   123.727    91.352    92.104

std_xxABCD =
   131.17   131.21   128.90   129.02   128.01   128.23

std_xxABCDf =
   131.19   131.24   128.89   129.01   128.01   128.23

std_xxABCDds =
   131.17   131.17   131.17   131.16   131.16   131.16

std_xxABCDdsf =
   131.25   131.24   131.24   131.24   131.24   131.24

max_std_xx = 131.21
max_std_xxf = 131.19
max_std_xx2 = 247.43
max_std_xx2f = 247.43
max_std_xx2alt = 170.74
max_std_xx2altf = 170.71
max_std_xx2sv = 247.43
max_std_xx2svf = 247.43
max_std_xx2svalt = 170.74
max_std_xx2svaltf = 170.81
max_std_xxABCD = 131.21
max_std_xxABCDf = 131.24
max_std_xxABCDds = 131.17
max_std_xxABCDdsf = 131.25
max_xx = 532.55
max_xxf = 531
max_xx2 = 985.22
max_xx2f = 987
max_xx2alt = 692.99
max_xx2altf = 690
max_xx2sv = 985.22
max_xx2svf = 985
max_xx2alt = 692.99
max_xx2altf = 690
max_xxABCD = 532.55
max_xxABCDf = 530
max_xxABCDds = 511.77
max_xxABCDdsf = 515
At fap Hf=-1.1297 (dB)

Testing Nk=7
ngABCDds = 6.2723e+04
ng = 3.1934
ngap = 13.000
ngSchur = 3.1934
ngSchurap = 13.000
ngABCD = 2.3100
ngABCDap = 7.0000
pow2pd =
   1.000000   2.000000   0.062500   0.125000   0.500000   1.000000   0.500000

ng2 = 2.0035
ng2ap = 8.0186
ngABCD2 = 2.3100
ngABCD2ap = 7.0000
pow2paltd =
   2.000000   2.000000   0.062500   0.125000   0.500000   2.000000   1.000000

ng2alt = 3.8000
ng2altap = 14.947
ngABCD2alt = 2.3100
ngABCD2altap = 7.0000
ng2sv = 2.3100
ng2svap = 7.0000
ng2svalt = 2.3100
ng2svaltap = 7.0000
est_varyd = 0.3494
est_varySchurd = 0.3494
varyd = 0.3561
est_vary2d = 0.2503
vary2d = 0.2532
est_vary2altd = 0.4000
vary2altd = 0.3943
est_vary2svd = 0.2758
vary2svd = 0.1963
est_vary2svaltd = 0.2758
vary2svaltd = 0.3276
est_varyABCDd = 0.2758
varyABCDd = 0.2743
est_varyABCDdsd = 5227.0
varyABCDdsd = 128.05
est_varyapd = 1.1667
est_varySchurapd = 1.1667
varyapd = 1.1758
est_vary2apd = 0.7515
vary2apd = 0.7425
est_vary2altapd = 1.3289
vary2altapd = 1.3078
est_varyABCDapd = 0.6667
varyABCDapd = 0.6697
std_xx =
   133.49   133.56   128.11   128.06   128.49   128.24   127.96

std_xxf =
   133.44   133.51   128.12   128.07   128.49   128.24   127.96

std_xx2 =
   196.26   137.49   173.21   145.63   167.19   192.80   184.48

std_xx2f =
   196.46   137.62   173.25   145.68   167.21   192.82   184.48

std_xx2alt =
    98.132   137.487   173.206   145.635   167.191    96.402    92.240

std_xx2altf =
    98.209   137.596   173.222   145.649   167.200    96.407    92.241

std_xx2sv =
   196.27   137.49   173.21   145.63   167.19   192.80   184.48

std_xx2svf =
   196.33   137.54   173.22   145.64   167.19   192.81   184.48

std_xx2svalt =
    98.133   137.490   173.208   145.635   167.185    96.402    92.240

std_xx2svaltf =
    98.183   137.562   173.209   145.631   167.186    96.406    92.242

std_xxABCD =
   133.49   133.56   128.11   128.06   128.48   128.24   127.96

std_xxABCDf =
   133.44   133.51   128.10   128.05   128.49   128.25   127.96

std_xxABCDds =
   133.49   133.49   133.49   133.49   133.49   133.50   133.50

std_xxABCDdsf =
   134.86   134.86   134.86   134.86   134.86   134.87   134.87

max_std_xx = 133.56
max_std_xxf = 133.51
max_std_xx2 = 196.26
max_std_xx2f = 196.46
max_std_xx2alt = 173.21
max_std_xx2altf = 173.22
max_std_xx2sv = 196.27
max_std_xx2svf = 196.33
max_std_xx2svalt = 173.21
max_std_xx2svaltf = 173.21
max_std_xxABCD = 133.56
max_std_xxABCDf = 133.51
max_std_xxABCDds = 133.50
max_std_xxABCDdsf = 134.87
max_xx = 629.19
max_xxf = 629
max_xx2 = 925.10
max_xx2f = 926
max_xx2alt = 719.30
max_xx2altf = 717
max_xx2sv = 925.10
max_xx2svf = 927
max_xx2alt = 719.30
max_xx2altf = 717
max_xxABCD = 629.19
max_xxABCDf = 631
max_xxABCDds = 629.19
max_xxABCDdsf = 660
At fap Hf=-1.7736 (dB)

Testing Nk=8
ngABCDds = 5.4052e+06
ng = 3.8291
ngap = 15.000
ngSchur = 3.8291
ngSchurap = 15.000
ngABCD = 2.6631
ngABCDap = 8.0000
pow2pd =
 Columns 1 through 7:
   1.000000   2.000000   0.031250   0.031250   0.500000   1.000000   0.250000
 Column 8:
   0.500000

ng2 = 2.5231
ng2ap = 10.007
ngABCD2 = 2.6631
ngABCD2ap = 8.0000
pow2paltd =
 Columns 1 through 7:
   2.000000   2.000000   0.031250   0.062500   0.500000   1.000000   0.500000
 Column 8:
   1.000000

ng2alt = 4.8504
ng2altap = 19.001
ngABCD2alt = 2.6631
ngABCD2altap = 8.0000
ng2sv = 2.6631
ng2svap = 8.0000
ng2svalt = 2.6631
ng2svaltap = 8.0000
est_varyd = 0.4024
est_varySchurd = 0.4024
varyd = 0.4096
est_vary2d = 0.2936
vary2d = 0.2926
est_vary2altd = 0.4875
vary2altd = 0.4935
est_vary2svd = 0.3053
vary2svd = 0.2251
est_vary2svaltd = 0.3053
vary2svaltd = 0.3829
est_varyABCDd = 0.3053
varyABCDd = 0.3058
est_varyABCDdsd = 4.5044e+05
varyABCDdsd = 4433.2
est_varyapd = 1.3333
est_varySchurapd = 1.3333
varyapd = 1.3508
est_vary2apd = 0.9173
vary2apd = 0.9161
est_vary2altapd = 1.6667
vary2altapd = 1.6996
est_varyABCDapd = 0.7500
varyABCDapd = 0.7610
std_xx =
   130.19   130.21   127.87   127.85   128.50   128.55   128.51   128.57

std_xxf =
   130.26   130.28   127.91   127.88   128.51   128.56   128.51   128.57

std_xx2 =
   193.98   134.53   155.45   233.00   129.54   134.96   184.19   184.45

std_xx2f =
   194.53   134.91   155.52   233.11   129.54   134.96   184.20   184.45

std_xx2alt =
    96.992   134.529   155.450   116.501   129.539   134.960    92.095    92.225

std_xx2altf =
    97.003   134.538   155.558   116.585   129.549   134.970    92.091    92.220

std_xx2sv =
   193.98   134.53   155.45   233.00   129.54   134.96   184.20   184.45

std_xx2svf =
   194.37   134.80   155.50   233.07   129.54   134.96   184.19   184.45

std_xx2svalt =
    96.991   134.534   155.451   116.501   129.538   134.959    92.099    92.227

std_xx2svaltf =
    97.000   134.542   155.535   116.565   129.560   134.981    92.104    92.229

std_xxABCD =
   130.19   130.21   127.87   127.85   128.50   128.55   128.51   128.57

std_xxABCDf =
   130.28   130.31   127.84   127.81   128.49   128.54   128.51   128.57

std_xxABCDds =
   130.19   130.19   130.19   130.19   130.20   130.20   130.20   130.20

std_xxABCDdsf =
   176.52   176.53   176.53   176.53   176.54   176.54   176.55   176.54

max_std_xx = 130.21
max_std_xxf = 130.28
max_std_xx2 = 233.00
max_std_xx2f = 233.11
max_std_xx2alt = 155.45
max_std_xx2altf = 155.56
max_std_xx2sv = 233.00
max_std_xx2svf = 233.07
max_std_xx2svalt = 155.45
max_std_xx2svaltf = 155.53
max_std_xxABCD = 130.21
max_std_xxABCDf = 130.31
max_std_xxABCDds = 130.20
max_std_xxABCDdsf = 176.55
max_xx = 604.22
max_xxf = 602
max_xx2 = 1101.2
max_xx2f = 1099
max_xx2alt = 708.27
max_xx2altf = 713
max_xx2sv = 1101.2
max_xx2svf = 1101
max_xx2alt = 708.27
max_xx2altf = 713
max_xxABCD = 604.22
max_xxABCDf = 607
max_xxABCDds = 478.50
max_xxABCDdsf = 629
At fap Hf=-3.2800 (dB)

Testing Nk=9
ngABCDds = 9.6770e+08
ng = 4.5143
ngap = 17.000
ngSchur = 4.5143
ngSchurap = 17.000
ngABCD = 3.0163
ngABCDap = 9.0000
pow2pd =
 Columns 1 through 6:
   1.0000e+00   1.0000e+00   7.8125e-03   1.5625e-02   2.5000e-01   5.0000e-01
 Columns 7 through 9:
   1.2500e-01   2.5000e-01   5.0000e-01

ng2 = 2.3878
ng2ap = 9.0195
ngABCD2 = 3.0163
ngABCD2ap = 9.0000
pow2paltd =
 Columns 1 through 7:
   1.000000   2.000000   0.015625   0.015625   0.500000   0.500000   0.125000
 Columns 8 and 9:
   0.250000   1.000000

ng2alt = 4.9312
ng2altap = 18.908
ngABCD2alt = 3.0163
ngABCD2altap = 9.0000
ng2sv = 3.0163
ng2svap = 9.0000
ng2svalt = 3.0163
ng2svaltap = 9.0000
est_varyd = 0.4595
est_varySchurd = 0.4595
varyd = 0.4834
est_vary2d = 0.2823
vary2d = 0.2916
est_vary2altd = 0.4943
vary2altd = 0.5384
est_vary2svd = 0.3347
vary2svd = 0.2230
est_vary2svaltd = 0.3347
vary2svaltd = 0.3596
est_varyABCDd = 0.3347
varyABCDd = 0.3375
est_varyABCDdsd = 8.0642e+07
varyABCDdsd = 5828.2
est_varyapd = 1.5000
est_varySchurapd = 1.5000
varyapd = 1.6128
est_vary2apd = 0.8350
vary2apd = 0.8574
est_vary2altapd = 1.6590
vary2altapd = 1.9369
est_varyABCDapd = 0.8333
varyABCDapd = 0.8498
std_xx =
 Columns 1 through 8:
   125.86   125.84   127.42   127.42   128.27   128.23   127.54   127.85
 Column 9:
   127.89

std_xxf =
 Columns 1 through 8:
   126.43   126.42   127.54   127.54   128.28   128.23   127.54   127.85
 Column 9:
   127.89

std_xx2 =
 Columns 1 through 8:
   144.34   199.33   219.67   156.73   195.37   168.07   150.96   176.51
 Column 9:
   184.21

std_xx2f =
 Columns 1 through 8:
   144.24   199.19   219.79   156.82   195.39   168.09   150.97   176.51
 Column 9:
   184.21

std_xx2alt =
 Columns 1 through 8:
   144.336    99.663   109.834   156.729    97.684   168.074   150.962   176.506
 Column 9:
    92.106

std_xx2altf =
 Columns 1 through 8:
   144.454    99.744   109.857   156.758    97.705   168.109   150.979   176.523
 Column 9:
    92.108

std_xx2sv =
 Columns 1 through 8:
   144.33   199.33   219.67   156.73   195.38   168.07   150.96   176.51
 Column 9:
   184.21

std_xx2svf =
 Columns 1 through 8:
   144.47   199.52   219.78   156.81   195.39   168.08   150.96   176.50
 Column 9:
   184.21

std_xx2svalt =
 Columns 1 through 8:
   144.334    99.664   109.834   156.732    97.688   168.070   150.961   176.506
 Column 9:
    92.107

std_xx2svaltf =
 Columns 1 through 8:
   144.507    99.781   109.868   156.781    97.708   168.108   150.977   176.517
 Column 9:
    92.108

std_xxABCD =
 Columns 1 through 8:
   125.85   125.84   127.42   127.42   128.28   128.22   127.54   127.85
 Column 9:
   127.89

std_xxABCDf =
 Columns 1 through 8:
   125.93   125.92   127.45   127.46   128.30   128.24   127.55   127.85
 Column 9:
   127.89

std_xxABCDds =
 Columns 1 through 8:
   125.85   125.85   125.85   125.85   125.85   125.85   125.85   125.85
 Column 9:
   125.84

std_xxABCDdsf =
   0   0   0   0   0   0   0   0   0

max_std_xx = 128.27
max_std_xxf = 128.28
max_std_xx2 = 219.67
max_std_xx2f = 219.79
max_std_xx2alt = 176.51
max_std_xx2altf = 176.52
max_std_xx2sv = 219.67
max_std_xx2svf = 219.78
max_std_xx2svalt = 176.51
max_std_xx2svaltf = 176.52
max_std_xxABCD = 128.28
max_std_xxABCDf = 128.30
max_std_xxABCDds = 125.85
max_std_xxABCDdsf = 0
max_xx = 546.01
max_xxf = 546
max_xx2 = 929.57
max_xx2f = 936
max_xx2alt = 662.98
max_xx2altf = 659
max_xx2sv = 929.57
max_xx2svf = 929
max_xx2alt = 662.98
max_xx2altf = 659
max_xxABCD = 546.01
max_xxABCDf = 546
max_xxABCDds = 441.67
max_xxABCDdsf = 0
At fap Hf=-6.0256 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog (octfile)"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
