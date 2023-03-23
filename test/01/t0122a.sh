#!/bin/sh

prog=ellip5NS_test.m

depends="test/ellip5NS_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlattice2Abcd.oct \
schurNSlatticeFilter.m KW.m optKW.m tf2Abcd.m svf.m bin2SD.oct crossWelch.m \
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
fc = 0.050000
n =
 Columns 1 through 6:
   6.6160e-03  -2.9674e-02   4.9860e-02  -2.6776e-02  -2.6776e-02   4.9860e-02
 Columns 7 and 8:
  -2.9674e-02   6.6160e-03

d =
    1.0000   -6.4328   17.9479  -28.1369   26.7559  -15.4281    4.9940   -0.7000

n60 = 1391
s10 =
 Columns 1 through 6:
   7.7668e-01   8.4822e-01   3.6434e-01   3.8757e-01   8.9744e-02   5.8424e-02
 Column 7:
   6.6160e-03

s11 =
   0.6299   0.5296   0.9313   0.9218   0.9960   0.9983   0.3088

s20 =
  -0.9536   0.9992  -0.9737   0.9892  -0.9815   0.9631  -0.7000

s00 =
   0.301051   0.040872   0.227879   0.146846   0.191295   0.269168   0.714168

s02 =
   0.9536  -0.9992   0.9737  -0.9892   0.9815  -0.9631   0.7000

s22 =
   0.301051   0.040872   0.227879   0.146846   0.191295   0.269168   0.714168

c =
 Columns 1 through 6:
   8.7941e-02   1.0844e-01   2.2359e-01   1.0313e-01   1.1900e-01   2.7668e-02
 Columns 7 and 8:
   1.8043e-02   6.6160e-03

S =
    0.0000         0         0         0         0         0         0         0
   -0.0000    0.0001         0         0         0         0         0         0
    0.0012   -0.0023    0.0012         0         0         0         0         0
   -0.0053    0.0154   -0.0155    0.0054         0         0         0         0
    0.0364   -0.1405    0.2089   -0.1413    0.0368         0         0         0
   -0.1887    0.9151   -1.8063    1.8129   -0.9253    0.1922         0         0
    0.6878   -4.0116    9.8867  -13.1741   10.0098   -4.1126    0.7142         0
   -0.7000    4.9940  -15.4281   26.7559  -28.1369   17.9479   -6.4328    1.0000

ng = 4.2777
ngap = 13.000
A =
   0.9536   0.3011        0        0        0        0        0
  -0.3008   0.9528   0.0409        0        0        0        0
   0.0120  -0.0379   0.9729   0.2279        0        0        0
  -0.0028   0.0088  -0.2252   0.9631   0.1468        0        0
   0.0004  -0.0013   0.0328  -0.1403   0.9709   0.1913        0
  -0.0001   0.0002  -0.0062   0.0263  -0.1822   0.9453   0.2692
   0.0000  -0.0000   0.0012  -0.0052   0.0357  -0.1849   0.6741

B =
        0
        0
        0
        0
        0
        0
   0.7142

C =
   0.087941   0.108435   0.223587   0.103127   0.119005   0.027668   0.018043

D = 6.6160e-03
Cap =
 Columns 1 through 6:
   1.5141e-05  -4.7961e-05   1.2295e-03  -5.2579e-03   3.6374e-02  -1.8868e-01
 Column 7:
   6.8781e-01

Dap = -0.7000
ngopt = 1.4987
ngoptap = 7.0000
ngdir = 2.4159e+11
ngdirap = 1.8054e+12
est_varyd = 0.4398
varyd = 0.4353
est_varyoptd = 0.2082
varyoptd = 0.2041
est_varydird = 2.0132e+10
varydird = 3.5149e+07
est_varyapd = 1.1667
varyapd = 1.1536
stdxx =
   121.13   120.71   128.78   129.06   130.18   129.96   128.18

stdxxopt =
   126.28   127.86   125.45   127.08   128.57   130.09   122.77

stdxxdir =
 Columns 1 through 6:
   2.0367e+09   2.0367e+09   2.0367e+09   2.0367e+09   2.0367e+09   2.0367e+09
 Column 7:
   2.0368e+09

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

