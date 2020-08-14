#!/bin/sh

prog=yalmip_test.m
depends="yalmip_test.m test_common.m SeDuMi_1_3/ SparsePOP303/ SDPT3/ YALMIP/"

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
For sedumi : solution = [ -0.000000  0.500000  0.083333  0.416667  0.166666  0.333334  0.250000  0.250000  0.333333  0.166667 ]
For sparsepop : solution = [  0.000000  0.500000  0.083333  0.416667  0.166666  0.333334  0.249999  0.250001  0.333331  0.166669 ]
For sdpt3 : solution = [ -0.000000  0.500000  0.083333  0.416667  0.166667  0.333333  0.250000  0.250000  0.333333  0.166667 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x5.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

