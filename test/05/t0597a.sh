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
   2.7680   1.8962  -0.5972  -1.4623
   1.8962   4.3723   0.6888  -0.8757
  -0.5972   0.6888   1.5620  -0.2290
  -1.4623  -0.8757  -0.2290   2.8364
Y=
   2.8364  -0.2289  -0.8758  -1.4623
  -0.2289   1.5619   0.6888  -0.5971
  -0.8758   0.6888   4.3724   1.8962
  -1.4623  -0.5971   1.8962   2.7679
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

