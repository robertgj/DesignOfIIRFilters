#!/bin/sh

prog=goldensection_test.m
depends="test/goldensection_test.m test_common.m goldstein.m armijo.m \
goldensection.m quadratic.m"

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

Testing armijo:
tau=1.55,f(-4.1+tau)=2.4025,iter=9,fiter=24
tau=0.125,f(-1.5+tau)=0.140625,iter=6,fiter=42
tau=0.05,f(-2+tau)=0.9025,iter=7,fiter=62

Testing goldstein:
tau=1.55,f(-4.1+tau)=2.4025,iter=9,fiter=86
tau=0.125,f(-1.5+tau)=0.140625,iter=6,fiter=104
tau=0.05,f(-2+tau)=0.9025,iter=7,fiter=124

Testing goldensection:
tau=1.55,f(-4.1+tau)=2.4025,iter=9,fiter=148
tau=0.125,f(-1.5+tau)=0.140625,iter=6,fiter=166
tau=0.05,f(-2+tau)=0.9025,iter=7,fiter=186
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
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

