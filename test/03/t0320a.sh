#!/bin/sh

prog=directFIRsymmetricGradSqErr_test.m
depends="directFIRsymmetricGradSqErr_test.m test_common.m \
directFIRsymmetricA.m directFIRsymmetricEsqPW.m directFIRsymmetricGradSqErr.m"

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
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
nchk=[ 10001 10002 20000 20001 40001 40002 50000 50001 ];
wa(nchk)*0.5/pi=[0.05 0.050005 0.099995 0.1 0.2 0.200005 0.249995 0.25 ];
Ad(nchk)=[ 0 0 0 1 1 0 0 0 ];
Wa(nchk)=[ 30 0 0 1 1 0 0 30 ];
tol =  0.000000010000
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok for $prog"; fail; fi

#
# this much worked
#
pass

