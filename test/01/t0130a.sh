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
ng =    1.9734e+10
ngopt =    1.3329e+00
ngorth =    2.0865e+00
ngib =    2.0865e+00
est_nvib =    5.0715e-01
nvibf =    5.1108e-01
rho =

   2.6856e-01
   1.4165e-01
   1.2704e-01
   5.8299e-02
   2.1251e-02
   5.5120e-03

ngpi =    2.0865e+00
gI =    2.5406e-01
est_nvgI =    3.2327e-01
nvpilpef =    3.0792e-01
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

