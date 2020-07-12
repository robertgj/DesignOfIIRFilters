#!/bin/sh

prog=peiFIRantisymmetric_flat_hilbert_test.m

depends="peiFIRantisymmetric_flat_hilbert_test.m test_common.m \
print_polynomial.m"

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
cat > test_h5.ok << 'EOF'
h5 = [ -0.000120162964, -0.000000000000, -0.001615524292, -0.000000000000, ... 
       -0.010385513306, -0.000000000000, -0.043619155884, -0.000000000000, ... 
       -0.145397186279, -0.000000000000, -0.610668182373, -0.000000000000, ... 
        0.610668182373, -0.000000000000,  0.145397186279, -0.000000000000, ... 
        0.043619155884, -0.000000000000,  0.010385513306, -0.000000000000, ... 
        0.001615524292, -0.000000000000,  0.000120162964 ];

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h25.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h5.ok peiFIRantisymmetric_flat_hilbert_test_h5_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h5.ok"; fail; fi

#
# this much worked
#
pass

