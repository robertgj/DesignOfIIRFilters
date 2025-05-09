#!/bin/sh

prog=schurexpand_test.m

descr="schurexpand_test.m (mfile)"

depends="test/schurexpand_test.m test_common.m check_octave_file.m \
schurdecomp.m schurexpand.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $descr
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
Using schurexpand mfile
warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 16 column 2

k =
  -0.8167   0.9982  -0.8844   0.9651  -0.9299   0.8869  -0.5636

S =
    0.0006         0         0         0         0         0         0         0
   -0.0008    0.0010         0         0         0         0         0         0
    0.0171   -0.0280    0.0172         0         0         0         0         0
   -0.0325    0.0897   -0.0924    0.0367         0         0         0         0
    0.1355   -0.4649    0.6735   -0.4728    0.1404         0         0         0
   -0.3549    1.5638   -2.9666    3.0064   -1.6281    0.3817         0         0
    0.7326   -3.8934    9.1556  -12.1157    9.5089   -4.2051    0.8261         0
   -0.5636    3.7557  -11.2004   19.3491  -20.9129   14.1672   -5.5903    1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 17 column 1

c =
 Columns 1 through 7:
  -0.055418   0.137744   0.200439   0.244231   0.218092   0.090615   0.039148
 Column 8:
   0.013694

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 18 column 1

dc =
 Columns 1 through 6:
   5.9755e-04  -8.4580e-04   1.7120e-02  -3.2500e-02   1.3548e-01  -3.5491e-01
 Columns 7 and 8:
   7.3261e-01  -5.6357e-01

warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 19 column 2

km =
  -0.8167   0.9982  -0.8844   0.9651  -0.9299   0.8869  -0.5636

Sm =
   -0.0006         0         0         0         0         0         0         0
    0.0008   -0.0010         0         0         0         0         0         0
   -0.0171    0.0280   -0.0172         0         0         0         0         0
    0.0325   -0.0897    0.0924   -0.0367         0         0         0         0
   -0.1355    0.4649   -0.6735    0.4728   -0.1404         0         0         0
    0.3549   -1.5638    2.9666   -3.0064    1.6281   -0.3817         0         0
   -0.7326    3.8934   -9.1556   12.1157   -9.5089    4.2051   -0.8261         0
    0.5636   -3.7557   11.2004  -19.3491   20.9129  -14.1672    5.5903   -1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 20 column 1

cm =
 Columns 1 through 7:
   0.055418  -0.137744  -0.200439  -0.244231  -0.218092  -0.090615  -0.039148
 Column 8:
  -0.013694

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 21 column 1

dcm =
 Columns 1 through 6:
  -5.9755e-04   8.4580e-04  -1.7120e-02   3.2500e-02  -1.3548e-01   3.5491e-01
 Columns 7 and 8:
  -7.3261e-01   5.6357e-01

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 22 column 1

dcmm =
 Columns 1 through 6:
   5.9755e-04  -8.4580e-04   1.7120e-02  -3.2500e-02   1.3548e-01  -3.5491e-01
 Columns 7 and 8:
   7.3261e-01  -5.6357e-01

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 30 column 2

k =
  -0.805776   0.999210  -0.785551   0.976849  -0.679467   0.609371  -0.028265

S =
    0.0018         0         0         0         0         0         0         0
   -0.0025    0.0031         0         0         0         0         0         0
    0.0769   -0.1240    0.0770         0         0         0         0         0
   -0.0977    0.2817   -0.2981    0.1244         0         0         0         0
    0.5680   -1.8178    2.6034   -1.8394    0.5815         0         0         0
   -0.5385    2.4777   -4.8884    5.2316   -3.0331    0.7926         0         0
    0.6091   -3.0103    7.1457   -9.9224    8.5025   -4.2393    0.9996         0
   -0.0283    0.7292   -3.2519    7.4291  -10.1284    8.5910   -4.2582    1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 31 column 1

c =
 Columns 1 through 7:
   0.090791   0.087717  -0.186099  -0.095525   0.287667   0.161757  -0.660897
 Column 8:
   0.340938

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 32 column 1

dc =
 Columns 1 through 6:
   1.8123e-03  -2.4658e-03   7.6920e-02  -9.7726e-02   5.6805e-01  -5.3852e-01
 Columns 7 and 8:
   6.0913e-01  -2.8265e-02

warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 33 column 2

km =
  -0.805776   0.999210  -0.785551   0.976849  -0.679467   0.609371  -0.028265

Sm =
   -0.0018         0         0         0         0         0         0         0
    0.0025   -0.0031         0         0         0         0         0         0
   -0.0769    0.1240   -0.0770         0         0         0         0         0
    0.0977   -0.2817    0.2981   -0.1244         0         0         0         0
   -0.5680    1.8178   -2.6034    1.8394   -0.5815         0         0         0
    0.5385   -2.4777    4.8884   -5.2316    3.0331   -0.7926         0         0
   -0.6091    3.0103   -7.1457    9.9224   -8.5025    4.2393   -0.9996         0
    0.0283   -0.7292    3.2519   -7.4291   10.1284   -8.5910    4.2582   -1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 34 column 1

cm =
 Columns 1 through 7:
   0.090791   0.087717  -0.186099  -0.095525   0.287667   0.161757  -0.660897
 Column 8:
   0.340938

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 35 column 1

dcm =
 Columns 1 through 6:
  -1.8123e-03   2.4658e-03  -7.6920e-02   9.7726e-02  -5.6805e-01   5.3852e-01
 Columns 7 and 8:
  -6.0913e-01   2.8265e-02

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 36 column 1

dcmm =
 Columns 1 through 6:
   1.8123e-03  -2.4658e-03   7.6920e-02  -9.7726e-02   5.6805e-01  -5.3852e-01
 Columns 7 and 8:
   6.0913e-01  -2.8265e-02

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 46 column 2

k =
  -0.3970   0.9350  -0.6589   0.6258  -0.3121

S =
   0.1815        0        0        0        0        0
  -0.0785   0.1977        0        0        0        0
   0.5212  -0.4282   0.5574        0        0        0
  -0.4882   1.0679  -1.0257   0.7410        0        0
   0.5945  -1.4489   2.2259  -1.7068   0.9500        0
  -0.3121   1.1866  -2.2564   2.8190  -1.9919   1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 47 column 1

c =
  -0.225839   0.158736   0.362673   0.353330   0.171004   0.049343

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 48 column 1

dc =
   0.181460  -0.078488   0.521186  -0.488228   0.594547  -0.312129

warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 49 column 2

km =
  -0.3970   0.9350  -0.6589   0.6258  -0.3121

Sm =
  -0.1815        0        0        0        0        0
   0.0785  -0.1977        0        0        0        0
  -0.5212   0.4282  -0.5574        0        0        0
   0.4882  -1.0679   1.0257  -0.7410        0        0
  -0.5945   1.4489  -2.2259   1.7068  -0.9500        0
   0.3121  -1.1866   2.2564  -2.8190   1.9919  -1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 50 column 1

cm =
  -0.225839   0.158736   0.362673   0.353330   0.171004   0.049343

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 51 column 1

dcm =
  -0.181460   0.078488  -0.521186   0.488228  -0.594547   0.312129

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 52 column 1

dcmm =
   0.181460  -0.078488   0.521186  -0.488228   0.594547  -0.312129

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 60 column 2

k =
  -0.269728   0.952677   0.055805   0.450264   0.155925

S =
   0.2578        0        0        0        0        0
  -0.0722   0.2677        0        0        0        0
   0.8389  -0.4638   0.8806        0        0        0
   0.0492   0.8143  -0.4176   0.8820        0        0
   0.4448  -0.1555   1.3226  -0.4429   0.9878        0
   0.1559   0.3803   0.0514   1.3145  -0.3782   1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 61 column 1

c =
   0.108554  -0.272622  -0.050916   0.499813  -0.430072   0.139910

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 62 column 1

dc =
   0.257767  -0.072203   0.838927   0.049219   0.444757   0.155925

warning: Using m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 33 column 1
    schurexpand_test at line 63 column 2

km =
  -0.269728   0.952677   0.055805   0.450264   0.155925

Sm =
  -0.2578        0        0        0        0        0
   0.0722  -0.2677        0        0        0        0
  -0.8389   0.4638  -0.8806        0        0        0
  -0.0492  -0.8143   0.4176  -0.8820        0        0
  -0.4448   0.1555  -1.3226   0.4429  -0.9878        0
  -0.1559  -0.3803  -0.0514  -1.3145   0.3782  -1.0000

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 64 column 1

cm =
   0.108554  -0.272622  -0.050916   0.499813  -0.430072   0.139910

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 65 column 1

dcm =
  -0.257767   0.072203  -0.838927  -0.049219  -0.444757  -0.155925

warning: Using m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 66 column 1

dcmm =
   0.257767  -0.072203   0.838927   0.049219   0.444757   0.155925

ans = 0
ans = 0
ans = 0
ans = 0
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $descr"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

