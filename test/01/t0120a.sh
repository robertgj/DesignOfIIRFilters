#!/bin/sh

prog=butt5NSSD_test.m

depends="butt5NSSD_test.m test_common.m \
spectralfactor.oct schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m flt2SD.m x2nextra.m bin2SD.oct schurNSlatticeFilter.m \
crossWelch.m tf2pa.m p2n60.m qroots.m qzsolve.oct"

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
fc = 0.05000000000
n =
 Columns 1 through 4:
   0.00005979578037   0.00029897890185   0.00059795780370   0.00059795780370
 Columns 5 and 6:
   0.00029897890185   0.00005979578037

d =
 Columns 1 through 5:
   1.000000000  -3.984543120   6.434867090  -5.253615170   2.165132910
 Column 6:
  -0.359928245

n60 = 73
Aap1 =
   1.000000000  -1.521690426   0.600000000

Aap2 =
   1.000000000  -2.462852694   2.087167726  -0.599880408

S =
 Columns 1 through 4:
   0.45849342188663   0.09546259603074   0.01357624981588   0.00180702212992
 Column 5:
   0.00005979578037

s10 =
   0.888697801   0.995433018   0.999907838   0.999998367   0.318662336

s11 =
  -0.980406843   0.978748271  -0.958088593   0.839774720  -0.359928245

s20 =
   0.196983303   0.205065409   0.286472074   0.542935006   0.932979988

s00 =
   0.980406843  -0.978748271   0.958088593  -0.839774720   0.359928245

s02 =
   0.196983303   0.205065409   0.286472074   0.542935006   0.932979988

s22 =
 Columns 1 through 4:
   0.28187473248396   0.14542368670960   0.03041748061744   0.00432623241881
 Columns 5 and 6:
   0.00057582989334   0.00005979578037

c =
 Columns 1 through 5:
   0.005861709             0             0             0             0
  -0.029174351   0.029757392             0             0             0
   0.142027837  -0.281513578   0.145111711             0             0
  -0.485317377   1.437287687  -1.457694715   0.506547495             0
   0.783493008  -3.148539935   4.870353769  -3.435497729   0.932979988
  -0.359928245   2.165132910  -5.253615170   6.434867090  -3.984543120
 Column 6:
             0
             0
             0
             0
             0
   1.000000000

nbits = 10
scale = 512
ndigits = 2
A1s10f =
  -0.937500000   0.625000000

A1s11f =
   0.312500000   0.750000000

A1s20f =
  -0.937500000   0.625000000

A1s00f =
   0.312500000   0.750000000

A1s02f =
   0.937500000  -0.625000000

A1s22f =
   0.312500000   0.750000000

A2s10f =
  -0.968750000   0.937500000  -0.625000000

A2s11f =
   0.248046875   0.312500000   0.750000000

A2s20f =
  -0.968750000   0.937500000  -0.625000000

A2s00f =
   0.248046875   0.312500000   0.750000000

A2s02f =
   0.968750000  -0.937500000   0.625000000

A2s22f =
   0.248046875   0.312500000   0.750000000

stdA1xxf =
   119.3200344   121.5537072

stdA2xxf =
   120.1149440   117.4119447   121.4899853

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

