#!/bin/sh

prog=allpass_LS1_test.m
depends="test/allpass_LS1_test.m test_common.m delayz.m allpass_LS1.m \
allpass_LS1_pole2coef.m allpass_LS1_coef2Abcd.m allpass_LS1_coef2ng.m \
allpass_filter_check_gradc1.m Abcd2tf.m H2Asq.m H2T.m H2P.m svf.m KW.m \
Abcd2ng.m Abcd2H.oct"

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
ngLS1 = 1.0000
est_varyd = 0.1667
varyd = 0.1670
ngLS1 = 1.0000
est_varyd = 0.1667
varyd = 0.1670
r1=0.090000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.165211
r1=0.190000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.161996
r1=0.290000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.174149
r1=0.390000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.165791
r1=0.490000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.163709
r1=0.590000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.165863
r1=0.690000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.164556
r1=0.790000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.165960
r1=0.890000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.159321
r1=0.990000,ngLS1=1.000000,est_varyd=0.166667,varyd=0.188292
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
