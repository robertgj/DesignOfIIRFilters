#!/bin/sh

prog=hofstetterFIRsymmetric_multiband_test.m

depends="test/hofstetterFIRsymmetric_multiband_test.m test_common.m \
print_polynomial.m hofstetterFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m qroots.m \
qzsolve.oct"

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
hM = [  -0.0069124566,   0.0077531943,   0.0019595959,  -0.0005177889, ... 
         0.0001182649,  -0.0063168091,   0.0014745510,  -0.0006395502, ... 
         0.0018024181,  -0.0104721027,   0.0209069674,   0.0112324220, ... 
        -0.0214733804,   0.0017516866,  -0.0314988245,   0.0168413105, ... 
         0.0289331993,  -0.0063863456,  -0.0032179597,   0.0109003138, ... 
         0.0150475050,  -0.0727626671,   0.0078394926,  -0.0351408173, ... 
         0.0672651896,   0.1895697499,  -0.1682471918,  -0.0573225385, ... 
        -0.0867759493,  -0.0462400577,   0.3400571569 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok hofstetterFIRsymmetric_multiband_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

