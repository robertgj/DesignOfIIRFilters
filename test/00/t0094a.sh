#!/bin/sh

prog=butt3NS_test.m

depends="test/butt3NS_test.m test_common.m delayz.m \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlatticeFilter.m \
svf.m KW.m optKW.m tf2Abcd.m crossWelch.m p2n60.m qroots.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
schurNSlattice2Abcd.oct qzsolve.oct"

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
   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =
   1.0000  -2.3741   1.9294  -0.5321

s10 =
   3.2096e-01   5.6957e-02   2.8982e-03

s11 =
   0.9471   0.9984   0.3230

s20 =
  -0.9743   0.9292  -0.5321

s00 =
   0.2252   0.3695   0.8467

s02 =
   0.9743  -0.9292   0.5321

s22 =
   0.2252   0.3695   0.8467

c =
   3.0538e-01   1.0349e-01   1.8395e-02   2.8982e-03

S =
   0.0705        0        0        0
  -0.3048   0.3129        0        0
   0.7868  -1.5915   0.8467        0
  -0.5321   1.9294  -2.3741   1.0000

ng = 1.1906
ngap = 5.0000
A =
   0.9743   0.2252        0
  -0.2092   0.9054   0.3695
   0.0443  -0.1916   0.4944

B =
        0
        0
   0.8467

C =
   0.305385   0.103493   0.018395

D = 2.8982e-03
Cap =
   0.070452  -0.304829   0.786773

Dap = -0.5321
K =
   1.0000e+00  -1.8735e-15  -1.6653e-16
  -1.8735e-15   1.0000e+00  -2.4980e-15
  -1.6653e-16  -2.4980e-15   1.0000e+00

W =
   0.3094   0.2363   0.1052
   0.2363   0.2951   0.1897
   0.1052   0.1897   0.1455

ngABCD = 0.7500
Kap =
   1.0000e+00  -1.8735e-15  -1.6653e-16
  -1.8735e-15   1.0000e+00  -2.4980e-15
  -1.6653e-16  -2.4980e-15   1.0000e+00

Wap =
   1.0000e+00  -1.9429e-15  -2.8588e-15
  -1.9429e-15   1.0000e+00  -3.4972e-15
  -2.8588e-15  -3.4972e-15   1.0000e+00

ngABCDap = 3.0000
ngopt = 0.4705
ngoptap = 3.0000
ngdir = 68.980
ngdirap = 818.90
est_varyd = 0.1825
varyd = 0.1819
est_varyABCDd = 0.1458
varyABCDd = 0.1450
est_varyoptd = 0.1225
varyoptd = 0.1215
est_varydird = 5.8317
varydird = 1.8148
est_varyapd = 0.5000
varyapd = 0.4913
stdxx =
   131.21   129.39   127.97

stdxxopt =
   130.37   129.38   130.94

stdxxdir =
   131.34   131.34   131.33

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

