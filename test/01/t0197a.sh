#!/bin/sh

prog=schurNSlattice2Abcd_test.m
descr="schurNSlattice2Abcd_test.m (mfile)"
depends="test/schurNSlattice2Abcd_test.m test_common.m check_octave_file.m \
schurNSlattice2Abcd.m tf2schurNSlattice.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct Abcd2tf.oct"

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
Using schurNSlattice2Abcd mfile
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 89 column 48

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 100 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 89 column 48

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 100 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 89 column 48

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 100 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 89 column 48

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 100 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 244 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 246 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 273 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 275 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 302 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 304 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 331 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 333 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 360 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 362 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 389 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 391 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 441 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 462 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 441 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 462 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 441 column 20

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 462 column 55

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 567 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 569 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 596 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 598 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 625 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 627 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 654 column 40

warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 656 column 40

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings.
#
echo "Running $descr"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

