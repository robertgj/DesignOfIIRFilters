#!/bin/sh

prog=allpass_dir1_retimed_test.m
depends="allpass_dir1_retimed_test.m test_common.m allpass_dir1_retimed.m \
allpass_dir1_retimed_pole2coef.m allpass_dir1_retimed_coef2Abcd.m \
allpass_dir1_retimed_coef2ng.m allpass_filter_check_gradc1.m Abcd2tf.m \
H2Asq.m H2T.m H2P.m svf.m KW.m Abcd2ng.m Abcd2H.oct"

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
rank([A,B])~=rows(A) (2)
rank([A,B])~=rows(A) (2)
ngdir1_retimed =  1.0000
est_varyd =  0.16667
varyd =  0.16736
rank([A,B])~=rows(A) (2)
ngdir1_retimed =  1.0000
est_varyd =  0.16667
varyd =  0.16736
rank([A,B])~=rows(A) (2)
r1=0.090000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.164384
rank([A,B])~=rows(A) (2)
r1=0.190000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.173847
rank([A,B])~=rows(A) (2)
r1=0.290000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.165766
rank([A,B])~=rows(A) (2)
r1=0.390000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.167281
rank([A,B])~=rows(A) (2)
r1=0.490000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.159383
rank([A,B])~=rows(A) (2)
r1=0.590000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.174961
rank([A,B])~=rows(A) (2)
r1=0.690000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.162487
rank([A,B])~=rows(A) (2)
r1=0.790000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.159936
rank([A,B])~=rows(A) (2)
r1=0.890000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.155546
rank([A,B])~=rows(A) (2)
r1=0.990000,ngdir1_retimed=1.000000,est_varyd=0.166667,varyd=0.141472
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
