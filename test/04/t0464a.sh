#!/bin/sh

prog=selesnickFIRsymmetric_flat_lowpass_test.m

depends="selesnickFIRsymmetric_flat_lowpass_test.m test_common.m \
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
hM = [    43.91080520,   372.91677572,  1494.48125212,  3697.49748369, ... 
        6212.16961215,  7361.28482012 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hA.ok << 'EOF'
hA = [  0.000010469152, -0.000141411051,  0.000818659827, -0.002541531296, ... 
        0.004055046948, -0.001227041697, -0.006392990391,  0.006672187250, ... 
        0.009840325260, -0.018250303821, -0.013299129424,  0.040971335274, ... 
        0.016130924425, -0.090969568851, -0.017947413523,  0.312986334192, ... 
        0.518568215452 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_flat_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hA.ok selesnickFIRsymmetric_flat_lowpass_test_hA_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA.ok"; fail; fi

#
# this much worked
#
pass

