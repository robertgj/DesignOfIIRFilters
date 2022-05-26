#!/bin/sh

prog=butt3OneM_test.m

depends="test/butt3OneM_test.m test_common.m \
schurexpand.oct schurdecomp.oct bin2SD.oct \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m \
schurOneMlattice2Abcd.oct schurOneMlatticeFilter.m KW.m crossWelch.m \
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
   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =
   1.0000  -2.3741   1.9294  -0.5321

k =
  -0.9743   0.9292  -0.5321

epsilon =
  -1  -1  -1

p =
   3.0386   0.3466   1.8095

c =
   1.0050e-01   2.9862e-01   1.0166e-02   2.8982e-03

S =
   0.0705        0        0        0
  -0.3048   0.3129        0        0
   0.7868  -1.5915   0.8467        0
  -0.5321   1.9294  -2.3741   1.0000

ng = 0.9823
ngap = 5.0000
est_varyd = 0.1652
varyd = 0.1654
est_varyapd = 0.5000
varyapd = 0.4913
stdxf =
   131.21   129.39   127.96

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

