#!/bin/sh

prog=schurOneMlattice2H_test.m
descr="schurOneMlattice2H_test.m (mfile)"
depends="schurOneMlattice2H_test.m test_common.m check_octave_file.m \
tf2schurOneMlattice.m schurOneMscale.m schurOneMlattice2H.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $descr
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
Using schurOneMlattice2H mfile
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 40 column 2
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 45 column 4
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 53 column 9
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 57 column 9
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 58 column 9
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 67 column 15
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 76 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 79 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 97 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 100 column 10
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 111 column 24
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 116 column 26
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 118 column 26
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 131 column 36
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 141 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 145 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 164 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 168 column 21
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 181 column 51
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 191 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 195 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 205 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 209 column 32
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 220 column 51
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 225 column 43
warning: Using Octave m-file version of function schurOneMlattice2H
warning: called from
    schurOneMlattice2H at line 43 column 1
    schurOneMlattice2H_test at line 227 column 43
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running $prog"
octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

