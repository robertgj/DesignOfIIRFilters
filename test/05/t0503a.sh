#!/bin/sh

prog=sedumi_rls_test.m
depends="sedumi_rls_test.m test_common.m"

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
info.numerr=0
y = [  2.2845  1.0484 -0.0331  0.2375  0.2043 ]
[eigK(x,K), eigK(c-At*y,K)]'=
 0.0000 -0.0000
 1.4142  3.2307
 0.0000 -0.0000
 1.4142  1.4827
x'*(c-At*y)=  3.47e-09
info.numerr=0
y = [  2.2844  1.0538 -0.1000  0.1875  0.2558 ]
eigK(c-At*y,K)'=[ 
 0.0000  0.0000  3.2307 -0.0000  1.4904 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

