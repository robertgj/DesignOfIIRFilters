#!/bin/sh

prog=sedumi_specfac_test.m
depends="sedumi_specfac_test.m test_common.m"

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
info.numerr = 0
X=mat(x) =
 [   0.0468 -0.0369 -0.3000
    -0.0369  0.0292  0.2369
    -0.3000  0.2369  1.9240
    ]
isdefinite(X) = 1
y = [ -0.0727  0.3130 -0.6849 ]
Z = mat(c-At*y) =
 [   2.0727  0.0000  0.0000
    -0.3130  1.0727  0.0000
     0.6849 -0.3130  0.0727
    ]
ZZ=(Z+Z')/2 = 
 [   2.0727 -0.1565  0.3424
    -0.1565  1.0727 -0.1565
     0.3424 -0.1565  0.0727
    ]
[eig(X), eigK(x,K), eig(ZZ)]' = 
 0.0000  0.0000  0.0000
 0.0000  0.0000  1.0583
 2.0000  2.0000  2.1597
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

