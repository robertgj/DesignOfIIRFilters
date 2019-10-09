#!/bin/sh

prog=roots2T_test.m
descr="roots2T_test.m (mfile)"

depends="roots2T_test.m roots2T.m test_common.m check_octave_file.m \
chebyshevT_expand.m chebyshevT.m chebyshevP.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $0 $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $0 $descr
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
Using roots2T mfile
warning: Using Octave m-file version of function roots2T()!
No arguments exception caught!
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 19 column 2
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 24 column 2
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 29 column 2
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 34 column 2
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 43 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
warning: Using Octave m-file version of function roots2T()!
warning: called from
    roots2T at line 29 column 3
    roots2T_test at line 55 column 5
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $descr"
octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

