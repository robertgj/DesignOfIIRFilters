#!/bin/sh

prog=yalmip_sdp_ellipsoid_test.m
depends="test/yalmip_sdp_ellipsoid_test.m test_common.m print_polynomial.m"

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
cat > test_z.ok << 'EOF'
z = [   0.476460,   0.526880,   0.529840,   0.513256, ... 
        0.562355,   0.532988,   0.429077,   0.499618, ... 
        0.463226,   0.503096 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_z.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_z.ok "yalmip_sdp_ellipsoid_test_z.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_z.ok"; fail; fi

#
# this much worked
#
pass

