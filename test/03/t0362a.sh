#!/bin/sh

prog=allpass_MH2dt_test.m
depends="allpass_MH2dt_test.m test_common.m allpass_MH2dt.m \
allpass_MH2dt_pole2coef.m allpass_MH2dt_coef2Abcd.m allpass_MH2dt_coef2ng.m \
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
rank([A,B])~=rows(A) (3)
rank([A,B])~=rows(A) (3)
rank([A,B])~=rows(A) (3)
ngMH2dt =  27.307
est_varyd =  2.3589
varyd =  1.4621
rank([A,B])~=rows(A) (3)
ngMH2dt =  121374.00884
est_varyd =  10114.58407
varyd =  5285.9
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
