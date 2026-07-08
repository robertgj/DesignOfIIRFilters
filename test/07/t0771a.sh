#!/bin/sh

prog=complex_tridiagonal_inverse_test.m
depends="test/complex_tridiagonal_inverse_test.m test_common.m \
tf2pa.m tf2schurOneMlattice.m schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMscale.m \
schurOneMAPlatticeDoublyPipelined2H.cc \
schurOneMAPlatticeDoublyPipelined2H.oct \
reprand.oct spectralfactor.oct qroots.oct schurdecomp.oct schurexpand.oct"

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
Caught no output arguments!
Caught insufficient input arguments!
Caught too many input arguments!
Incorrect number of output arguments!
Incorrect number of output arguments!
Incorrect number of output arguments!
Incorrect length input arguments!
Done!
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

mkoctfile -DTEST_COMPLEX_TRIDIAGONAL_INVERSE \
          -o complex_tridiagonal_inverse.oct \
          schurOneMAPlatticeDoublyPipelined2H.cc

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

