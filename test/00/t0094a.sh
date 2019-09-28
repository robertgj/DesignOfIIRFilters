#!/bin/sh

prog=butt3NS_test.m

depends="butt3NS_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlattice2Abcd.oct \
schurNSlatticeFilter.m svf.m KW.m optKW.m tf2Abcd.m crossWelch.m"

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
   0.0028982   0.0086946   0.0086946   0.0028982

d =
   1.00000  -2.37409   1.92936  -0.53208

s10 =
   0.3209629   0.0569565   0.0028982

s11 =
   0.94709   0.99838   0.32297

s20 =
  -0.97432   0.92923  -0.53208

s00 =
   0.22518   0.36951   0.84670

s02 =
   0.97432  -0.92923   0.53208

s22 =
   0.22518   0.36951   0.84670

c =
   0.3053850   0.1034929   0.0183952   0.0028982

S =
   0.07045   0.00000   0.00000   0.00000
  -0.30483   0.31286   0.00000   0.00000
   0.78677  -1.59152   0.84670   0.00000
  -0.53208   1.92936  -2.37409   1.00000

ng =  1.1906
ngap =  5.0000
A =
   0.97432   0.22518   0.00000
  -0.20925   0.90536   0.36951
   0.04427  -0.19156   0.49442

B =
   0.00000
   0.00000
   0.84670

C =
   0.305385   0.103493   0.018395

D =  0.0028982
Cap =
   0.070452  -0.304829   0.786773

Dap = -0.53208
K =
   1.0000e+00  -1.7764e-15   9.7145e-16
  -1.7764e-15   1.0000e+00  -2.3315e-15
   9.7145e-16  -2.3315e-15   1.0000e+00

W =
   0.30944   0.23626   0.10521
   0.23626   0.29506   0.18969
   0.10521   0.18969   0.14550

ngABCD =  0.75000
Kap =
   1.0000e+00  -1.7764e-15   9.7145e-16
  -1.7764e-15   1.0000e+00  -2.3315e-15
   9.7145e-16  -2.3315e-15   1.0000e+00

Wap =
   1.0000e+00  -1.9429e-15  -2.8588e-15
  -1.9429e-15   1.0000e+00  -3.4972e-15
  -2.8588e-15  -3.4972e-15   1.0000e+00

ngABCDap =  3.0000
ngopt =  0.47049
ngoptap =  3.0000
ngdir =  68.980
ngdirap =  818.90
est_varyd =  0.18255
varyd =  0.18266
est_varyABCDd =  0.14583
varyABCDd =  0.14448
est_varyoptd =  0.12254
varyoptd =  0.12191
est_varydird =  5.8317
varydird =  1.8078
est_varyapd =  0.50000
varyapd =  0.49645
stdxx =
   131.32   129.47   127.97

stdxxopt =
   130.39   129.57   131.00

stdxxdir =
   131.32   131.32   131.32

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

