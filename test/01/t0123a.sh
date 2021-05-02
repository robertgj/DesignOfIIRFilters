#!/bin/sh

prog=ellip5OneM_test.m

depends="ellip5OneM_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurOneMscale.m \
tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m schurOneMlattice2Abcd.oct \
schurOneMlatticeFilter.m KW.m bin2SD.oct crossWelch.m p2n60.m qroots.m \
qzsolve.oct"

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
n60 = 339
k =
  -0.9657   0.9906  -0.9805   0.9620  -0.6961

epsilon =
   1   1   1   1   1

p =
   0.5798   4.3893   0.3018   3.0407   0.4233

c =
   4.0898e-01   3.0904e-02   4.9245e-01   1.1926e-02   4.8375e-02   7.3597e-03

S =
   0.0014        0        0        0        0        0
  -0.0051   0.0053        0        0        0        0
   0.0382  -0.0741   0.0386        0        0        0
  -0.1923   0.5639  -0.5675   0.1961        0        0
   0.6907  -2.7025   4.0505  -2.7547   0.7180        0
  -0.6961   3.6326  -7.6908   8.2614  -4.5064   1.0000

ng = 2.5504
ngap = 9.0000
est_varyd = 0.2959
varyd = 0.3006
est_varyapd = 0.8333
varyapd = 0.7960
stdxxf =
   129.01   128.33   129.65   129.36   128.47

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

