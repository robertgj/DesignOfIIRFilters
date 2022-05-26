#!/bin/sh

prog=clenshaw_gaussian_test.m
depends="test/clenshaw_gaussian_test.m test_common.m print_polynomial.m"

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
# Test scripts
#
cat > test_ak_coef.ok << 'EOF'
ak= = [  0.9315190686,  0.0000000000, -0.4158196500,  0.0000000000, ... 
         0.0998610074,  0.0000000000, -0.0161108841, -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ak_coef.ok"; fail; fi

cat > test_ak_fixed_point_coef.ok << 'EOF'
ak_fixed_point= = [  119,    0,  -53,    0, ... 
                      13,    0,   -2,    0 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ak_fixed_pointcoef.ok"; \
                      fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test_ak_coef.ok clenshaw_gaussian_test_ak_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ak_coef.ok"; fail; fi

diff -Bb test_ak_fixed_point_coef.ok clenshaw_gaussian_test_ak_fixed_point_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ak_fixed_point_coef.ok"; fail;fi

#
# this much worked
#
pass
