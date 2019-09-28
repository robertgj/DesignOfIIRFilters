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

k =
  -0.97432   0.92923  -0.53208

epsilon =
  -1  -1  -1

p =
   3.03862   0.34657   1.80947

c =
   0.1005013   0.2986163   0.0101661   0.0028982

S =
   0.07045   0.00000   0.00000   0.00000
  -0.30483   0.31286   0.00000   0.00000
   0.78677  -1.59152   0.84670   0.00000
  -0.53208   1.92936  -2.37409   1.00000

ng =  0.98228
ngap =  5.0000
est_varyd =  0.16519
varyd =  0.16571
est_varyapd =  0.50000
varyapd =  0.49645
stdxf =
   131.32   129.47   127.97

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

