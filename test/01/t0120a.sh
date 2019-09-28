#!/bin/sh

prog=butt5NSSD_test.m

depends="butt5NSSD_test.m test_common.m \
spectralfactor.oct schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m flt2SD.m x2nextra.m bin2SD.oct schurNSlatticeFilter.m \
crossWelch.m tf2pa.m qroots.m qzsolve.oct"

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
 Columns 1 through 5:
   0.000059796   0.000298979   0.000597958   0.000597958   0.000298979
 Column 6:
   0.000059796

d =
   1.00000  -3.98454   6.43487  -5.25362   2.16513  -0.35993

Aap1 =
   1.00000  -1.52169   0.60000

Aap2 =
   1.00000  -2.46285   2.08717  -0.59988

S =
   0.458493422   0.095462596   0.013576250   0.001807022   0.000059796

s10 =
   0.88870   0.99543   0.99991   1.00000   0.31866

s11 =
  -0.98041   0.97875  -0.95809   0.83977  -0.35993

s20 =
   0.19698   0.20507   0.28647   0.54294   0.93298

s00 =
   0.98041  -0.97875   0.95809  -0.83977   0.35993

s02 =
   0.19698   0.20507   0.28647   0.54294   0.93298

s22 =
 Columns 1 through 5:
   0.281874732   0.145423687   0.030417481   0.004326232   0.000575830
 Column 6:
   0.000059796

c =
   0.00586   0.00000   0.00000   0.00000   0.00000   0.00000
  -0.02917   0.02976   0.00000   0.00000   0.00000   0.00000
   0.14203  -0.28151   0.14511   0.00000   0.00000   0.00000
  -0.48532   1.43729  -1.45769   0.50655   0.00000   0.00000
   0.78349  -3.14854   4.87035  -3.43550   0.93298   0.00000
  -0.35993   2.16513  -5.25362   6.43487  -3.98454   1.00000

nbits =  10
scale =  512
ndigits =  2
A1s10f =
  -0.93750   0.62500

A1s11f =
   0.31250   0.75000

A1s20f =
  -0.93750   0.62500

A1s00f =
   0.31250   0.75000

A1s02f =
   0.93750  -0.62500

A1s22f =
   0.31250   0.75000

A2s10f =
  -0.96875   0.93750  -0.62500

A2s11f =
   0.24805   0.31250   0.75000

A2s20f =
  -0.96875   0.93750  -0.62500

A2s00f =
   0.24805   0.31250   0.75000

A2s02f =
   0.96875  -0.93750   0.62500

A2s22f =
   0.24805   0.31250   0.75000

ans =
   119.62   121.59

ans =
   120.44   117.57   121.53

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

