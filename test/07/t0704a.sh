#!/bin/sh

prog=qroots_test.m
descr="qroots_test.m (mfile)"
depends="test/qroots_test.m test_common.m check_octave_file.m \
print_pole_zero.m tf2x.m zp2x.m qroots.m"

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
Using qroots mfile
warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 22 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 26 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 30 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 35 column 3

qroots did catch complex coefficients
warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 42 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 47 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 52 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 60 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 66 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 78 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 101 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    qroots_test at line 119 column 1

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    tf2x at line 53 column 1
    qroots_test at line 132 column 2

warning: Using builtin function roots()!
warning: called from
    qroots at line 25 column 3
    tf2x at line 56 column 1
    qroots_test at line 132 column 2

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test.coef << 'EOF'
Ux=0,Vx=2,Mx=0,Qx=8,Rx=1
x = [  1.0000000000, ...
      -0.1307212017, -0.0668061890, ...
       0.5476073344,  0.7118255059,  0.7878154723,  0.9216278425, ...
       1.5186811109,  0.9636442613,  0.7282955096,  1.3538908874 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.coef"; fail; fi

#
# run and see if the results match. 
#
echo "Running $descr"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test.coef qroots_test_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.coef"; fail; fi

#
# this much worked
#
pass

