#!/bin/sh

prog=yalmip_moment_test.m
depends="test/yalmip_moment_test.m test_common.m"

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
YALMIP nonconvex quadratic programming moment example
value(sol.xoptimal{1}) = [  0.24 -1.00 -1.00  1.00  1.00 ]
value(sol.xoptimal{1})'*Q*value(sol.xoptimal{1}) = -80.94
value(sol.xoptimal{2}) = [ -0.24  1.00  1.00 -1.00 -1.00 ]
value(sol.xoptimal{2})'*Q*value(sol.xoptimal{2}) = -80.94

YALMIP moment relaxation solvemoment example
For k=1 : 
obj = -4.00
For k=2 : 
obj = -4.00

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

