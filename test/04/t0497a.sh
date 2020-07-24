#!/bin/sh

prog=Lu_remarks_example_4_test.m
depends="Lu_remarks_example_4_test.m \
test_common.m print_polynomial.m SeDuMi_1_3/"

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
cat > test_r_s.ok << 'EOF'
r_s = [   1.951800,   0.879500 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x5.ok"; fail; fi

cat > test_s_s.ok << 'EOF'
s_s = [   2.400000,   2.536235 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_y5.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r_s.ok Lu_remarks_example_4_test_r_s_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r_s.ok"; fail; fi

diff -Bb test_s_s.ok Lu_remarks_example_4_test_s_s_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_s_s.ok"; fail; fi

#
# this much worked
#
pass

