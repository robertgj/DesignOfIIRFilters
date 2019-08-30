#!/bin/sh

prog=allpass_GM2_test.m
depends="allpass_GM2_test.m test_common.m allpass_GM2.m \
allpass_GM2_pole2coef.m allpass_GM2_coef2Abcd.m allpass_GM2_coef2ng.m \
allpass_filter_check_gradc1c2.m Abcd2tf.m H2Asq.m H2T.m H2P.m svf.m KW.m \
Abcd2ng.m Abcd2H.oct"

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
ngGM2 =  2.0000
est_varyd =  0.25000
varyd =  0.25016
ngGM2 =  1.00000
ep1=-1,ep2=-1,est_varyd=0.166667,varyd=200.776867
ngGM2 =  1.00000
ep1=-1,ep2=1,est_varyd=0.166667,varyd=0.165843
ngGM2 =  1.00000
ep1=1,ep2=-1,est_varyd=0.166667,varyd=200.776867
ngGM2 =  1.0000
ep1=1,ep2=1,est_varyd=0.166667,varyd=0.165843
ngGM2 =  2.0000
est_varyd =  0.25000
varyd =  0.21906
ngGM2 =  2.0000
est_varyd =  0.25000
varyd =  0.28041
ngGM2 =  2.0000
est_varyd =  0.25000
varyd =  0.27686
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
octave-cli -q $prog > test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
