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
   2.7572   1.9036  -0.6061  -1.4600
   1.9036   4.3749   0.6925  -0.8752
  -0.6061   0.6925   1.5785  -0.2037
  -1.4600  -0.8752  -0.2037   2.8251
Y=
   2.8353  -0.2430  -0.8764  -1.4572
  -0.2430   1.5558   0.6843  -0.5872
  -0.8764   0.6843   4.3757   1.8995
  -1.4572  -0.5872   1.8995   2.7683
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

