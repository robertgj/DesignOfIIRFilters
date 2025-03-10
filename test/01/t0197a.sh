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
warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 93 column 48

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 106 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 93 column 48

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 106 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 93 column 48

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 106 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 42 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 93 column 48

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 106 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 250 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 252 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 279 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 281 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 308 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 310 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 337 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 339 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 366 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 368 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 395 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 397 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 447 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 471 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 447 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 471 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 447 column 20

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 471 column 55

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 576 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 578 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 605 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 607 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 634 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 636 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 663 column 40

warning: Using m-file version of function schurNSlattice2Abcd!
warning: called from
    schurNSlattice2Abcd at line 49 column 3
    schurNSlattice2Abcd_test at line 665 column 40

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
