#!/bin/sh

prog=yalmip_kyp_finsler_test.m

depends="test/yalmip_kyp_finsler_test.m test_common.m tf2Abcd.m"

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
N=6, generalised KYP solved!
N=6, Finsler generalised KYP solved!
N=7, generalised KYP solved!
N=7, Finsler generalised KYP solved!
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test.ok yalmip_kyp_finsler_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test.ok"; fail; fi

#
# this much worked
#
pass
