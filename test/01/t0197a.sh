#!/bin/sh

prog=schurNSlattice2Abcd_test.m
descr="schurNSlattice2Abcd_test.m (mfile)"
depends="schurNSlattice2Abcd_test.m test_common.m check_octave_file.m \
schurNSlattice2Abcd.m tf2schurNSlattice.m Abcd2tf.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct"

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
    schurNSlattice2Abcd_test at line 33 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 54 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 33 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 54 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 33 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 54 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 195 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 197 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 224 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 226 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 253 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 255 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 282 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 284 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 311 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 313 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 340 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 342 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 392 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 413 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 392 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 413 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 392 column 20
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 413 column 55
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 518 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 520 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 547 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 549 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40
warning: Using Octave m-file version of function schurNSlattice2Abcd()!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40
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

