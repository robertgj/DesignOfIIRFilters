#!/bin/sh

prog=error_feedback_test.m

depends="error_feedback_test.m test_common.m \
optKW.m KW.m Abcd2tf.m tf2Abcd.m \
factorFdoubleprime.m FprimeToFdoubleprime.m orthogonaliseTF.m \
tf2schurOneMlattice.m schurdecomp.oct schurOneMscale.m schurexpand.oct \
schurOneMlattice2Abcd.oct C1D1FToG0primeFprime.m svf.m crossWelch.m"
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
ng =  19733626174.06045
ngopt =  1.3329
ngorth =  2.0865
ngib =  2.0865
est_nvib =  0.50715
nvibf =  0.51108
rho =
   0.2685608
   0.1416492
   0.1270416
   0.0582988
   0.0212510
   0.0055120

ngpi =  2.0865
gI =  0.25406
est_nvgI =  0.32327
nvpilpef =  0.30792
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

