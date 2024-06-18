#!/bin/sh

prog=Abcd2tf_test.m
descr="Abcd2tf_test.m (octfile)"
depends="test/Abcd2tf_test.m test_common.m tf2schurOneMlattice.m \
check_octave_file.m print_polynomial.m KW.m optKW.m schurOneMscale.m tf2Abcd.m \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct Abcd2tf.oct"

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
Using Abcd2tf octfile
Invalid call to Abcd2tf.  Correct usage is:

[N,D,B]=Abcd2tf(A,b,c,d)
element number 4 undefined in return list
Invalid call to Abcd2tf.  Correct usage is:

[N,D,B]=Abcd2tf(A,b,c,d)
element number 4 undefined in return list
A is empty
A.rows() != A.columns()
A.rows() != b.rows()
A.rows() != b.rows()
A.rows() != c.columns()
A.rows() != c.columns()
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
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
