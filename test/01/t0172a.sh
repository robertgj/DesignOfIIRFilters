#!/bin/sh

prog=schurOneMlattice2Abcd_test.m

descr="schurOneMlattice2Abcd_test.m (mfile)"

depends="test/schurOneMlattice2Abcd_test.m test_common.m check_octave_file.m \
schurOneMlattice2Abcd.m tf2schurOneMlattice.m Abcd2tf.m schurOneMscale.m \
schurdecomp.oct schurexpand.oct reprand.oct"

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
Using schurOneMlattice2Abcd mfile
warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 38 column 20

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 59 column 61

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 38 column 20

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 59 column 61

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 38 column 20

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 59 column 61

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 38 column 20

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 59 column 61

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 74 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 75 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 78 column 30

warning: Using Octave m-file version of function schurOneMlattice2Abcd()!
warning: called from
    schurOneMlattice2Abcd at line 40 column 3
    schurOneMlattice2Abcd_test at line 79 column 30

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings.
#
echo "Running $descr"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

