#!/bin/sh

prog=yalmip_bmibnb_test.m
depends="test/yalmip_bmibnb_test.m test_common.m"

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


YALMIP globaloptimization examples



YALMIP globaloptimization example 1

value(t)=-0.9414


YALMIP globaloptimization example 2

value(trace(P))= 0.4974


YALMIP globaloptimization example 3

value(trace(P))= 0.4884


YALMIP globaloptimization example 4a

value(-t)=-2.5000


YALMIP globaloptimization example 4b

value(-t)=-2.4836


YALMIP globaloptimization example 4c

value(-t)=-2.4667


YALMIP globaloptimization example 4d

value(-t)=-2.4667


YALMIP non-convex quadratic programming example

For bmibnb : 
value(x) = [ -0.2734  1.0000  1.0000 -1.0000 -1.0000 ]
real(value(x'*Q*x)) = -80.9164
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

