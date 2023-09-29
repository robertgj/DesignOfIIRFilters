#!/bin/sh

prog=lmirank_test.m
depends="test/lmirank_test.m test_common.m lmirank.m"

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
cat > lmirank_test.ok << 'EOF'
X=
   2.7662   1.9064  -0.6199  -1.4656
   1.9064   4.3786   0.6941  -0.8760
  -0.6199   0.6941   1.6028  -0.1936
  -1.4656  -0.8760  -0.1936   2.8281
Y=
   2.8376  -0.2293  -0.8773  -1.4601
  -0.2293   1.5595   0.6854  -0.5907
  -0.8773   0.6854   4.3805   1.9025
  -1.4601  -0.5907   1.9025   2.7639
info.rank=
   1   1   6
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb lmirank_test.ok lmirank_test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb lmirank_test.ok"; fail; fi

#
# this much worked
#
pass

