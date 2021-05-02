#!/bin/sh

prog=allpass_AL7c_retimed_test.m
depends="allpass_AL7c_retimed_test.m test_common.m allpass_AL7c_retimed.m \
allpass_AL7c_retimed_pole2coef.m allpass_AL7c_retimed_coef2Abcd.m \
allpass_AL7c_retimed_coef2ng.m allpass_filter_check_gradc1.m \
allpass_filter_check_gradc1c2.m Abcd2tf.m H2Asq.m H2T.m H2P.m svf.m KW.m \
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
rank([A,B])~=rows(A) (4)
rank([A,B])~=rows(A) (4)
rank([A,B])~=rows(A) (4)
ngAL7c_retimed = 2.8352
est_varyd = 0.3196
varyd = 0.3384
rank([A,B])~=rows(A) (4)
ngAL7c_retimed = 1.0000
est_varyd = 0.1667
varyd = 0.1714
rank([A,B])~=rows(A) (4)
ngAL7c_retimed = 1.3322
est_varyd = 0.1943
varyd = 0.1984
rank([A,B])~=rows(A) (4)
ngAL7c_retimed = 9900.8
est_varyd = 825.15
varyd = 800.90
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
