#!/bin/sh

prog=ellip5NS_test.m

depends="ellip5NS_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlattice2Abcd.oct \
schurNSlatticeFilter.m KW.m optKW.m tf2Abcd.m svf.m bin2SD.oct crossWelch.m"

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
fc =  0.050000
n =
 Columns 1 through 6:
   0.0066160  -0.0296739   0.0498599  -0.0267756  -0.0267756   0.0498599
 Columns 7 and 8:
  -0.0296739   0.0066160

d =
 Columns 1 through 7:
    1.00000   -6.43277   17.94792  -28.13694   26.75590  -15.42807    4.99399
 Column 8:
   -0.69997

s10 =
 Columns 1 through 6:
   0.7766829   0.8482179   0.3643394   0.3875734   0.0897440   0.0584240
 Column 7:
   0.0066160

s11 =
   0.62989   0.52965   0.93127   0.92184   0.99596   0.99829   0.30882

s20 =
  -0.95361   0.99916  -0.97369   0.98916  -0.98153   0.96309  -0.69997

s00 =
   0.301051   0.040872   0.227879   0.146846   0.191295   0.269168   0.714168

s02 =
   0.95361  -0.99916   0.97369  -0.98916   0.98153  -0.96309   0.69997

s22 =
   0.301051   0.040872   0.227879   0.146846   0.191295   0.269168   0.714168

c =
 Columns 1 through 6:
   0.0879413   0.1084353   0.2235875   0.1031270   0.1190050   0.0276677
 Columns 7 and 8:
   0.0180427   0.0066160

S =
 Columns 1 through 7:
    0.00002    0.00000    0.00000    0.00000    0.00000    0.00000    0.00000
   -0.00005    0.00005    0.00000    0.00000    0.00000    0.00000    0.00000
    0.00123   -0.00235    0.00123    0.00000    0.00000    0.00000    0.00000
   -0.00526    0.01542   -0.01555    0.00540    0.00000    0.00000    0.00000
    0.03637   -0.14054    0.20887   -0.14130    0.03677    0.00000    0.00000
   -0.18868    0.91514   -1.80635    1.81295   -0.92527    0.19223    0.00000
    0.68781   -4.01163    9.88669  -13.17407   10.00979   -4.11263    0.71417
   -0.69997    4.99399  -15.42807   26.75590  -28.13694   17.94792   -6.43277
 Column 8:
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    1.00000

ng =  4.2777
ngap =  13.000
A =
   0.95361   0.30105   0.00000   0.00000   0.00000   0.00000   0.00000
  -0.30080   0.95281   0.04087   0.00000   0.00000   0.00000   0.00000
   0.01198  -0.03795   0.97288   0.22788   0.00000   0.00000   0.00000
  -0.00277   0.00879  -0.22522   0.96313   0.14685   0.00000   0.00000
   0.00040  -0.00128   0.03282  -0.14034   0.97089   0.19130   0.00000
  -0.00008   0.00024  -0.00616   0.02634  -0.18224   0.94531   0.26917
   0.00001  -0.00005   0.00121  -0.00515   0.03565  -0.18493   0.67414

B =
   0.00000
   0.00000
   0.00000
   0.00000
   0.00000
   0.00000
   0.71417

C =
   0.087941   0.108435   0.223587   0.103127   0.119005   0.027668   0.018043

D =  0.0066160
Cap =
 Columns 1 through 5:
   0.000015141  -0.000047961   0.001229507  -0.005257874   0.036374205
 Columns 6 and 7:
  -0.188680791   0.687810190

Dap = -0.69997
ngopt =  1.4987
ngoptap =  7.0000
ngdir =    2.4159e+11
ngdirap =    1.8058e+12
est_varyd =  0.43981
varyd =  0.46637
est_varyoptd =  0.20823
varyoptd =  0.21323
est_varydird =  20132358279.97749
varydird =  34465065.78378
est_varyapd =  1.1667
varyapd =  1.2239
stdxx =
   123.13   122.69   130.24   129.99   130.70   130.78   128.44

stdxxopt =
   130.56   126.84   124.61   129.21   129.37   127.07   130.04

stdxxdir =
 Columns 1 through 4:
   2063641443.31045   2063879289.55100   2064025067.13074   2064085219.00257
 Columns 5 through 7:
   2064093229.81281   2064098448.72273   2064149654.88132

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

