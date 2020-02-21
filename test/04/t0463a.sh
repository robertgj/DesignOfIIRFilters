#!/bin/sh

prog=mcclellanFIRsymmetric_flat_lowpass_test.m

depends="mcclellanFIRsymmetric_flat_lowpass_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m"

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
cat > test_hM.ok << 'EOF'
hM = [    56.17896774,   466.93894436,  1839.26934699,  4492.82391996, ... 
        7488.61684242,  8849.58705438 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hA.ok << 'EOF'
hA = [  0.000013394110, -0.000183343493,  0.001083363085, -0.003486589406, ... 
        0.006051274414, -0.003407242506, -0.006369164439,  0.009523748743, ... 
        0.008065137563, -0.021430848277, -0.009486047978,  0.043915909948, ... 
        0.010310734167, -0.093052907047, -0.010646959048,  0.313738455002, ... 
        0.510722170324 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_flat_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hA.ok mcclellanFIRsymmetric_flat_lowpass_test_hA_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA.ok"; fail; fi

#
# this much worked
#
pass

