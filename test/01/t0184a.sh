#!/bin/sh

prog=schurOneMAPlattice2H_test.m
descr="schurOneMAPlattice2H_test.m (octfile)"
depends="test/schurOneMAPlattice2H_test.m test_common.m check_octave_file.m \
tf2schurOneMlattice.m schurOneMscale.m tf2pa.m schurOneMAPlattice2Abcd.m \
schurOneMAPlattice2H.oct schurOneMlattice2Abcd.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.m qzsolve.oct \
Abcd2H.oct"

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
Using schurOneMAPlattice2H octfile
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. .
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

