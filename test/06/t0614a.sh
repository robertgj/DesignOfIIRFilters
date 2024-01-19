#!/bin/sh

prog=yalmip_parabolic_convex_bmi_test.m

depends="test/yalmip_parabolic_convex_bmi_test.m test_common.m"

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

Kheirandishfard example

eta= 1.00000,k=19,y=[-1.23020; 2.39875]

Henrion example

eta= 2.00000,k=12,x=[ 2.00000;-0.00000; 2.00000],fx=-6.00000
BMI constraint failed at eta= 2.00000,fx=-6.00000,cx=-2.00000

eta= 3.00000,k=15,x=[ 2.00000; 0.00000; 0.00000],fx=-4.00000
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test.ok yalmip_parabolic_convex_bmi_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test.ok"; fail; fi

#
# this much worked
#
pass

