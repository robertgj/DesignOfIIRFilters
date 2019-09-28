#!/bin/sh

prog=schurOneMAPlattice2H_test.m
descr="schurOneMAPlattice2H_test.m (mfile)"
depends="schurOneMAPlattice2H_test.m test_common.m check_octave_file.m \
schurOneMAPlattice2H.m tf2schurOneMlattice.m schurOneMscale.m tf2pa.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
complex_zhong_inverse.oct qroots.m qzsolve.oct"

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
echo $here
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
Using schurOneMAPlattice2H mfile
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 34 column 4
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 35 column 4
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 46 column 13
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 50 column 11
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 51 column 11
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 58 column 13
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 62 column 11
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 63 column 11
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 73 column 20
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 83 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 86 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 83 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 86 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 98 column 20
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 108 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 111 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 108 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 111 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 108 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 111 column 12
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 120 column 31
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 126 column 32
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 129 column 32
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 138 column 31
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 144 column 32
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 147 column 32
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 159 column 43
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 171 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 177 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 171 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 177 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 191 column 43
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 203 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 209 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 203 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 209 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 203 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 209 column 25
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 223 column 59
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 229 column 49
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 232 column 49
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 244 column 59
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 250 column 49
warning: Using Octave m-file version of function schurOneMAPlattice2H
warning: called from
    schurOneMAPlattice2H at line 43 column 1
    schurOneMAPlattice2H_test at line 253 column 49
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress grpdelay() and mfile warnings.
#
echo "Running octave-cli -q " $prog
octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

