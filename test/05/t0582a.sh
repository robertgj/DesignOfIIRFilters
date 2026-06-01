#!/bin/sh

prog=schurOneMlatticeFilter_test.m

depends="test/schurOneMlatticeFilter_test.m test_common.m \
schurOneMlatticeFilter.m tf2schurOneMlattice.m schurOneMscale.m \
schurOneMlatticeNoiseGain.m schurOneMlatticeRetimedNoiseGain.m \
KW.m p2n60.m svf.m crossWelch.m tf2Abcd.m print_polynomial.m \
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
varyd = 0.1348
est_vary2d = 0.1124
vary2d = 0.1061
est_vary2altd = 0.1124
vary2altd = 0.1061
est_vary2svd = 0.1300
vary2svd = 0.1089
est_vary2svaltd = 0.1300
vary2svaltd = 0.1089
est_varyABCDd = 0.1300
varyABCDd = 0.1304
est_varyABCDdsd = 0.1288
varyABCDdsd = 0.1223
est_varyapd = 0.3333
est_varySchurapd = 0.3333
varyapd = 0.3346
est_vary2apd = 0.2380
vary2apd = 0.2313
est_vary2altapd = 0.2380
vary2altapd = 0.2313
est_varyABCDapd = 0.2500
varyABCDapd = 0.2508
std_xx =
   127.90   128.04

std_xxf =
   127.90   128.04

std_xx2 =
   138.29   181.01

std_xx2f =
   138.33   181.07

std_xx2alt =
   138.29   181.01

std_xx2altf =
   138.33   181.07

std_xx2sv =
   138.29   181.01

std_xx2svf =
   138.29   181.01

std_xx2svalt =
   138.29   181.01

std_xx2svaltf =
   138.29   181.01

std_xxABCD =
   127.90   128.04

std_xxABCDf =
   127.90   128.04

std_xxABCDds =
   127.90   127.90

std_xxABCDdsf =
   127.90   127.90

max_std_xx = 128.04
max_std_xxf = 128.04
max_std_xx2 = 181.01
max_std_xx2f = 181.07
max_std_xx2alt = 181.01
max_std_xx2altf = 181.07
max_std_xx2sv = 181.01
max_std_xx2svf = 181.01
max_std_xx2svalt = 181.01
max_std_xx2svaltf = 181.01
max_std_xxABCD = 128.04
max_std_xxABCDf = 128.04
max_std_xxABCDds = 127.90
max_std_xxABCDdsf = 127.90
max_xx = 355.04
max_xxf = 355
max_xx2 = 455.15
max_xx2f = 455
max_xx2alt = 455.15
max_xx2altf = 455
max_xx2sv = 455.15
max_xx2svf = 455
max_xx2alt = 455.15
max_xx2altf = 455
max_xxABCD = 355.04
max_xxABCDf = 354
max_xxABCDds = 355.04
max_xxABCDdsf = 355
At fap Hf=-1.0032 (dB)

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
varyd = 0.1715
est_vary2d = 0.1186
vary2d = 0.1181
est_vary2altd = 0.2246
vary2altd = 0.2228
est_vary2svd = 0.1584
vary2svd = 0.1137
est_vary2svaltd = 0.1584
vary2svaltd = 0.2041
est_varyABCDd = 0.1584
varyABCDd = 0.1583
est_varyABCDdsd = 0.2022
varyABCDdsd = 0.1611
est_varyapd = 0.5000
est_varySchurapd = 0.5000
varyapd = 0.4999
est_vary2apd = 0.2450
vary2apd = 0.2436
est_vary2altapd = 0.7300
vary2altapd = 0.7325
est_varyABCDapd = 0.3333
varyABCDapd = 0.3350
std_xx =
   127.79   128.00   127.89

std_xxf =
   127.80   128.00   127.89

std_xx2 =
   249.36   206.29   189.87

std_xx2f =
   249.36   206.29   189.88

std_xx2alt =
   124.679   103.146    94.934

std_xx2altf =
   124.681   103.145    94.942

std_xx2sv =
   249.36   206.29   189.87

std_xx2svf =
   249.35   206.28   189.87

std_xx2svalt =
   124.678   103.144    94.935

std_xx2svaltf =
   124.678   103.144    94.934

std_xxABCD =
   127.79   128.00   127.89

std_xxABCDf =
   127.79   128.00   127.89

std_xxABCDds =
   127.79   127.79   127.79

std_xxABCDdsf =
   127.79   127.79   127.79

max_std_xx = 128.00
max_std_xxf = 128.00
max_std_xx2 = 249.36
max_std_xx2f = 249.36
max_std_xx2alt = 124.68
max_std_xx2altf = 124.68
max_std_xx2sv = 249.36
max_std_xx2svf = 249.35
max_std_xx2svalt = 124.68
max_std_xx2svaltf = 124.68
max_std_xxABCD = 128.00
max_std_xxABCDf = 128.00
max_std_xxABCDds = 127.79
max_std_xxABCDdsf = 127.79
max_xx = 454.46
max_xxf = 453
max_xx2 = 883.40
max_xx2f = 884
max_xx2alt = 441.70
max_xx2altf = 442
max_xx2sv = 883.40
max_xx2svf = 885
max_xx2alt = 441.70
max_xx2altf = 442
max_xxABCD = 454.46
max_xxABCDf = 454
max_xxABCDds = 452.72
max_xxABCDdsf = 453
At fap Hf=-1.0065 (dB)

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
varyd = 0.2098
est_vary2d = 0.1474
vary2d = 0.1483
est_vary2altd = 0.2686
vary2altd = 0.2695
est_vary2svd = 0.1876
vary2svd = 0.1354
est_vary2svaltd = 0.1876
vary2svaltd = 0.2448
est_varyABCDd = 0.1876
varyABCDd = 0.1861
est_varyABCDdsd = 0.6920
varyABCDdsd = 0.2949
est_varyapd = 0.6667
est_varySchurapd = 0.6667
varyapd = 0.6656
est_vary2apd = 0.3775
vary2apd = 0.3742
est_vary2altapd = 0.9434
vary2altapd = 0.9331
est_varyABCDapd = 0.4167
varyABCDapd = 0.4208
std_xx =
   127.82   127.94   127.80   128.01

std_xxf =
   127.82   127.93   127.79   128.01

std_xx2 =
   194.55   160.80   193.42   184.87

std_xx2f =
   194.54   160.80   193.42   184.87

std_xx2alt =
    97.273   160.800    96.711    92.434

std_xx2altf =
    97.279   160.808    96.712    92.436

std_xx2sv =
   194.54   160.80   193.42   184.87

std_xx2svf =
   194.55   160.81   193.42   184.87

std_xx2svalt =
    97.272   160.805    96.711    92.434

std_xx2svaltf =
    97.271   160.803    96.710    92.432

std_xxABCD =
   127.82   127.95   127.80   128.01

std_xxABCDf =
   127.82   127.94   127.80   128.01

std_xxABCDds =
   127.82   127.83   127.83   127.83

std_xxABCDdsf =
   127.83   127.84   127.84   127.84

max_std_xx = 128.01
max_std_xxf = 128.01
max_std_xx2 = 194.55
max_std_xx2f = 194.54
max_std_xx2alt = 160.80
max_std_xx2altf = 160.81
max_std_xx2sv = 194.54
max_std_xx2svf = 194.55
max_std_xx2svalt = 160.80
max_std_xx2svaltf = 160.80
max_std_xxABCD = 128.01
max_std_xxABCDf = 128.01
max_std_xxABCDds = 127.83
max_std_xxABCDdsf = 127.84
max_xx = 570.70
max_xxf = 571
max_xx2 = 762.47
max_xx2f = 762
max_xx2alt = 717.27
max_xx2altf = 717
max_xx2sv = 762.47
max_xx2svf = 763
max_xx2alt = 717.27
max_xx2altf = 717
max_xxABCD = 570.70
max_xxABCDf = 571
max_xxABCDds = 500.97
max_xxABCDdsf = 501
At fap Hf=-1.0168 (dB)

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
varyd = 0.2495
est_vary2d = 0.1787
vary2d = 0.1805
est_vary2altd = 0.2185
vary2altd = 0.2214
est_vary2svd = 0.2170
vary2svd = 0.1622
est_vary2svaltd = 0.2170
vary2svaltd = 0.1845
est_varyABCDd = 0.2170
varyABCDd = 0.2192
est_varyABCDdsd = 6.2372
varyABCDdsd = 1.0069
est_varyapd = 0.8333
est_varySchurapd = 0.8333
varyapd = 0.8386
est_vary2apd = 0.5149
vary2apd = 0.5050
est_vary2altapd = 0.7009
vary2altapd = 0.6972
est_varyABCDapd = 0.5000
varyABCDapd = 0.5077
std_xx =
   127.82   127.87   127.61   127.80   127.75

std_xxf =
   127.85   127.91   127.62   127.81   127.75

std_xx2 =
   137.66   209.61   153.37   169.36   176.44

std_xx2f =
   137.68   209.64   153.37   169.37   176.44

std_xx2alt =
   137.66   104.81   153.37   169.36   176.44

std_xx2altf =
   137.68   104.82   153.37   169.37   176.44

std_xx2sv =
   137.66   209.61   153.37   169.36   176.43

std_xx2svf =
   137.65   209.59   153.36   169.36   176.44

std_xx2svalt =
   137.66   104.81   153.37   169.36   176.43

std_xx2svaltf =
   137.67   104.81   153.36   169.36   176.43

std_xxABCD =
   127.82   127.87   127.61   127.81   127.75

std_xxABCDf =
   127.83   127.88   127.61   127.81   127.75

std_xxABCDds =
   127.82   127.82   127.82   127.82   127.82

std_xxABCDdsf =
   127.85   127.85   127.85   127.85   127.85

max_std_xx = 127.87
max_std_xxf = 127.91
max_std_xx2 = 209.61
max_std_xx2f = 209.64
max_std_xx2alt = 176.44
max_std_xx2altf = 176.44
max_std_xx2sv = 209.61
max_std_xx2svf = 209.59
max_std_xx2svalt = 176.43
max_std_xx2svaltf = 176.43
max_std_xxABCD = 127.87
max_std_xxABCDf = 127.88
max_std_xxABCDds = 127.82
max_std_xxABCDdsf = 127.85
max_xx = 612.06
max_xxf = 613
max_xx2 = 1003.3
max_xx2f = 1008
max_xx2alt = 649.97
max_xx2altf = 650
max_xx2sv = 1003.3
max_xx2svf = 1004
max_xx2alt = 649.97
max_xx2altf = 650
max_xxABCD = 612.06
max_xxABCDf = 611
max_xxABCDds = 603.52
max_xxABCDdsf = 604
At fap Hf=-1.0325 (dB)

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
varyd = 0.2973
est_vary2d = 0.1741
vary2d = 0.1733
est_vary2altd = 0.3686
vary2altd = 0.3630
est_vary2svd = 0.2464
vary2svd = 0.1513
est_vary2svaltd = 0.2464
vary2svaltd = 0.3064
est_varyABCDd = 0.2464
varyABCDd = 0.2495
est_varyABCDdsd = 125.09
varyABCDdsd = 7.6717
est_varyapd = 1.0000
est_varySchurapd = 1.0000
varyapd = 1.0138
est_vary2apd = 0.4604
vary2apd = 0.4611
est_vary2altapd = 1.2962
vary2altapd = 1.2926
est_varyABCDapd = 0.5833
varyABCDapd = 0.5901
std_xx =
   127.74   127.75   127.44   127.47   127.62   128.06

std_xxf =
   127.80   127.81   127.44   127.48   127.62   128.06

std_xx2 =
   231.60   166.23   244.26   244.47   182.14   183.97

std_xx2f =
   231.59   166.22   244.25   244.47   182.14   183.97

std_xx2alt =
   115.802   166.234   122.130   122.235    91.071    91.985

std_xx2altf =
   115.761   166.173   122.110   122.208    91.066    91.985

std_xx2sv =
   231.61   166.23   244.26   244.48   182.14   183.97

std_xx2svf =
   231.57   166.21   244.27   244.48   182.15   183.97

std_xx2svalt =
   115.803   166.233   122.130   122.238    91.071    91.985

std_xx2svaltf =
   115.781   166.199   122.126   122.237    91.076    91.988

std_xxABCD =
   127.74   127.75   127.44   127.48   127.62   128.06

std_xxABCDf =
   127.73   127.74   127.44   127.48   127.62   128.06

std_xxABCDds =
   127.74   127.74   127.74   127.74   127.74   127.74

std_xxABCDdsf =
   127.91   127.91   127.91   127.91   127.91   127.91

max_std_xx = 128.06
max_std_xxf = 128.06
max_std_xx2 = 244.47
max_std_xx2f = 244.47
max_std_xx2alt = 166.23
max_std_xx2altf = 166.17
max_std_xx2sv = 244.48
max_std_xx2svf = 244.48
max_std_xx2svalt = 166.23
max_std_xx2svaltf = 166.20
max_std_xxABCD = 128.06
max_std_xxABCDf = 128.06
max_std_xxABCDds = 127.74
max_std_xxABCDdsf = 127.91
max_xx = 589.58
max_xxf = 590
max_xx2 = 1069.0
max_xx2f = 1068
max_xx2alt = 716.93
max_xx2altf = 716
max_xx2sv = 1069.0
max_xx2svf = 1067
max_xx2alt = 716.93
max_xx2altf = 716
max_xxABCD = 589.58
max_xxABCDf = 589
max_xxABCDds = 589.58
max_xxABCDdsf = 590
At fap Hf=-1.1527 (dB)

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
varyd = 0.3482
est_vary2d = 0.2503
vary2d = 0.2548
est_vary2altd = 0.4000
vary2altd = 0.3932
est_vary2svd = 0.2758
vary2svd = 0.1972
est_vary2svaltd = 0.2758
vary2svaltd = 0.3306
est_varyABCDd = 0.2758
varyABCDd = 0.2697
est_varyABCDdsd = 5227.0
varyABCDdsd = 127.47
est_varyapd = 1.1667
est_varySchurapd = 1.1667
varyapd = 1.1733
est_vary2apd = 0.7515
vary2apd = 0.7524
est_vary2altapd = 1.3289
vary2altapd = 1.3337
est_varyABCDapd = 0.6667
varyABCDapd = 0.6489
std_xx =
   127.63   127.62   127.52   127.59   127.70   127.98   127.77

std_xxf =
   127.59   127.58   127.54   127.60   127.70   127.98   127.77

std_xx2 =
   187.66   131.38   172.41   145.10   166.16   192.41   184.21

std_xx2f =
   187.77   131.46   172.44   145.12   166.16   192.40   184.21

std_xx2alt =
    93.828   131.375   172.411   145.098   166.161    96.206    92.105

std_xx2altf =
    93.922   131.506   172.453   145.136   166.190    96.218    92.107

std_xx2sv =
   187.66   131.37   172.42   145.10   166.16   192.41   184.21

std_xx2svf =
   187.72   131.42   172.41   145.09   166.15   192.41   184.21

std_xx2svalt =
    93.828   131.375   172.415   145.098   166.162    96.206    92.104

std_xx2svaltf =
    93.926   131.511   172.445   145.124   166.165    96.205    92.103

std_xxABCD =
   127.63   127.62   127.53   127.59   127.70   127.98   127.77

std_xxABCDf =
   127.72   127.71   127.54   127.60   127.70   127.98   127.77

std_xxABCDds =
   127.63   127.63   127.63   127.63   127.63   127.63   127.63

std_xxABCDdsf =
   128.19   128.19   128.19   128.19   128.19   128.19   128.19

max_std_xx = 127.98
max_std_xxf = 127.98
max_std_xx2 = 192.41
max_std_xx2f = 192.40
max_std_xx2alt = 172.41
max_std_xx2altf = 172.45
max_std_xx2sv = 192.41
max_std_xx2svf = 192.41
max_std_xx2svalt = 172.42
max_std_xx2svaltf = 172.45
max_std_xxABCD = 127.98
max_std_xxABCDf = 127.98
max_std_xxABCDds = 127.63
max_std_xxABCDdsf = 128.19
max_xx = 635.72
max_xxf = 637
max_xx2 = 859.51
max_xx2f = 860
max_xx2alt = 859.51
max_xx2altf = 862
max_xx2sv = 859.51
max_xx2svf = 859
max_xx2alt = 859.51
max_xx2altf = 862
max_xxABCD = 635.72
max_xxABCDf = 635
max_xxABCDds = 497.50
max_xxABCDdsf = 511
At fap Hf=-1.9004 (dB)

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
varyd = 0.3980
est_vary2d = 0.2936
vary2d = 0.2931
est_vary2altd = 0.4875
vary2altd = 0.4892
est_vary2svd = 0.3053
vary2svd = 0.2214
est_vary2svaltd = 0.3053
vary2svaltd = 0.3869
est_varyABCDd = 0.3053
varyABCDd = 0.3046
est_varyABCDdsd = 4.5044e+05
varyABCDdsd = 4363.4
est_varyapd = 1.3333
est_varySchurapd = 1.3333
varyapd = 1.3068
est_vary2apd = 0.9173
vary2apd = 0.9180
est_vary2altapd = 1.6667
vary2altapd = 1.6400
est_varyABCDapd = 0.7500
varyABCDapd = 0.7539
std_xx =
   126.95   126.94   127.17   127.20   127.55   127.58   127.64   128.03

std_xxf =
   127.13   127.12   127.24   127.27   127.55   127.58   127.64   128.03

std_xx2 =
   189.17   131.15   154.60   231.83   128.58   133.94   182.95   183.68

std_xx2f =
   189.68   131.51   154.69   231.96   128.60   133.96   182.96   183.68

std_xx2alt =
    94.583   131.154   154.601   115.913   128.579   133.944    91.474    91.839

std_xx2altf =
    94.540   131.088   154.547   115.872   128.567   133.937    91.467    91.839

std_xx2sv =
   189.17   131.15   154.60   231.83   128.58   133.95   182.95   183.68

std_xx2svf =
   189.43   131.33   154.67   231.92   128.59   133.95   182.95   183.68

std_xx2svalt =
    94.584   131.155   154.603   115.913   128.579   133.946    91.473    91.838

std_xx2svaltf =
    94.599   131.171   154.682   115.974   128.593   133.958    91.475    91.840

std_xxABCD =
   126.95   126.94   127.17   127.20   127.55   127.58   127.64   128.03

std_xxABCDf =
   126.92   126.91   127.19   127.21   127.54   127.57   127.63   128.03

std_xxABCDds =
   126.95   126.96   126.96   126.96   126.96   126.96   126.96   126.96

std_xxABCDdsf =
   162.18   162.18   162.18   162.18   162.18   162.18   162.18   162.19

max_std_xx = 128.03
max_std_xxf = 128.03
max_std_xx2 = 231.83
max_std_xx2f = 231.96
max_std_xx2alt = 154.60
max_std_xx2altf = 154.55
max_std_xx2sv = 231.83
max_std_xx2svf = 231.92
max_std_xx2svalt = 154.60
max_std_xx2svaltf = 154.68
max_std_xxABCD = 128.03
max_std_xxABCDf = 128.03
max_std_xxABCDds = 126.96
max_std_xxABCDdsf = 162.19
max_xx = 681.50
max_xxf = 683
max_xx2 = 1192.0
max_xx2f = 1198
max_xx2alt = 828.50
max_xx2altf = 832
max_xx2sv = 1192.0
max_xx2svf = 1190
max_xx2alt = 828.50
max_xx2altf = 832
max_xxABCD = 681.50
max_xxABCDf = 681
max_xxABCDds = 456.18
max_xxABCDdsf = 593
At fap Hf=-3.3852 (dB)

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
varyd = 0.5063
est_vary2d = 0.2823
vary2d = 0.2948
est_vary2altd = 0.4943
vary2altd = 0.5685
est_vary2svd = 0.3347
vary2svd = 0.2218
est_vary2svaltd = 0.3347
vary2svaltd = 0.3478
est_varyABCDd = 0.3347
varyABCDd = 0.3362
est_varyABCDdsd = 8.0642e+07
varyABCDdsd = 5783.2
est_varyapd = 1.5000
est_varySchurapd = 1.5000
varyapd = 1.6978
est_vary2apd = 0.8350
vary2apd = 0.8807
est_vary2altapd = 1.6590
vary2altapd = 1.8707
est_varyABCDapd = 0.8333
varyABCDapd = 0.8353
std_xx =
 Columns 1 through 8:
   124.62   124.60   127.56   127.57   127.85   127.96   127.76   128.02
 Column 9:
   127.72

std_xxf =
 Columns 1 through 8:
   125.11   125.09   127.70   127.72   127.88   127.98   127.76   128.02
 Column 9:
   127.72

std_xx2 =
 Columns 1 through 8:
   142.92   197.36   219.91   156.92   194.73   167.72   151.22   176.75
 Column 9:
   183.97

std_xx2f =
 Columns 1 through 8:
   143.01   197.48   219.86   156.88   194.70   167.69   151.21   176.75
 Column 9:
   183.97

std_xx2alt =
 Columns 1 through 8:
   142.922    98.678   109.957   156.915    97.364   167.723   151.216   176.751
 Column 9:
    91.983

std_xx2altf =
 Columns 1 through 8:
   142.541    98.415   109.996   156.969    97.346   167.687   151.199   176.739
 Column 9:
    91.981

std_xx2sv =
 Columns 1 through 8:
   142.92   197.36   219.91   156.91   194.74   167.72   151.22   176.75
 Column 9:
   183.97

std_xx2svf =
 Columns 1 through 8:
   143.25   197.82   219.97   156.96   194.73   167.71   151.22   176.75
 Column 9:
   183.96

std_xx2svalt =
 Columns 1 through 8:
   142.920    98.680   109.955   156.914    97.369   167.722   151.218   176.752
 Column 9:
    91.983

std_xx2svaltf =
 Columns 1 through 8:
   142.940    98.692   109.962   156.925    97.373   167.733   151.217   176.751
 Column 9:
    91.983

std_xxABCD =
 Columns 1 through 8:
   124.62   124.60   127.56   127.57   127.86   127.96   127.76   128.02
 Column 9:
   127.72

std_xxABCDf =
 Columns 1 through 8:
   125.00   124.98   127.63   127.64   127.89   127.99   127.77   128.03
 Column 9:
   127.72

std_xxABCDds =
 Columns 1 through 8:
   124.62   124.63   124.62   124.62   124.63   124.62   124.63   124.63
 Column 9:
   124.63

std_xxABCDdsf =
   0   0   0   0   0   0   0   0   0

max_std_xx = 128.02
max_std_xxf = 128.02
max_std_xx2 = 219.91
max_std_xx2f = 219.86
max_std_xx2alt = 176.75
max_std_xx2altf = 176.74
max_std_xx2sv = 219.91
max_std_xx2svf = 219.97
max_std_xx2svalt = 176.75
max_std_xx2svaltf = 176.75
max_std_xxABCD = 128.02
max_std_xxABCDf = 128.03
max_std_xxABCDds = 124.63
max_std_xxABCDdsf = 0
max_xx = 555.58
max_xxf = 553
max_xx2 = 924.19
max_xx2f = 921
max_xx2alt = 728.23
max_xx2altf = 725
max_xx2sv = 924.19
max_xx2svf = 928
max_xx2alt = 728.23
max_xx2altf = 725
max_xxABCD = 555.58
max_xxABCDf = 555
max_xxABCDds = 452.18
max_xxABCDdsf = 0
At fap Hf=-5.7584 (dB)
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
