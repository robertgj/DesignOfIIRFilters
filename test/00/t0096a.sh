#!/bin/sh

prog=butt3OneM_test.m

depends="butt3OneM_test.m test_common.m \
schurexpand.oct schurdecomp.oct bin2SD.oct \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m \
schurOneMlattice2Abcd.oct schurOneMlatticeFilter.m KW.m crossWelch.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
fc =    5.0000e-02
n =

   2.8982e-03   8.6946e-03   8.6946e-03   2.8982e-03

d =

   1.0000e+00  -2.3741e+00   1.9294e+00  -5.3208e-01

k =

  -9.7432e-01   9.2923e-01  -5.3208e-01

epsilon =

  -1.0000e+00  -1.0000e+00  -1.0000e+00

p =

   3.0386e+00   3.4657e-01   1.8095e+00

c =

   1.0050e-01   2.9862e-01   1.0166e-02   2.8982e-03

S =

   7.0452e-02   0.0000e+00   0.0000e+00   0.0000e+00
  -3.0483e-01   3.1286e-01   0.0000e+00   0.0000e+00
   7.8677e-01  -1.5915e+00   8.4670e-01   0.0000e+00
  -5.3208e-01   1.9294e+00  -2.3741e+00   1.0000e+00

ng =    9.8228e-01
ngap =    5.0000e+00
est_varyd =    1.6519e-01
varyd =    1.6571e-01
est_varyapd =    5.0000e-01
varyapd =    4.9645e-01
stdxf =

   1.3132e+02   1.2947e+02   1.2797e+02

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

