#!/bin/sh

prog=selesnickFIRsymmetric_flat_lowpass_test.m

depends="test/selesnickFIRsymmetric_flat_lowpass_test.m test_common.m \
print_polynomial.m selesnickFIRsymmetric_flat_lowpass.m local_max.m \
lagrange_interp.m xfr2tf.m directFIRsymmetricA.m"

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
hM = [    43.91080519,   372.91677570,  1494.48125206,  3697.49748358, ... 
        6212.16961201,  7361.28481996 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hA.ok << 'EOF'
hA = [  0.000010469152, -0.000141411051,  0.000818659827, -0.002541531294, ... 
        0.004055046944, -0.001227041686, -0.006392990415,  0.006672187289, ... 
        0.009840325210, -0.018250303773, -0.013299129454,  0.040971335274, ... 
        0.016130924455, -0.090969568900, -0.017947413469,  0.312986334142, ... 
        0.518568215500 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_flat_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hA.ok selesnickFIRsymmetric_flat_lowpass_test_hA_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA.ok"; fail; fi

#
# this much worked
#
pass

