#!/bin/sh

prog=directFIRnonsymmetric_kyp_finsler_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_finsler_lowpass_test.m test_common.m \
delayz.m print_polynomial.m konopacki.m directFIRnonsymmetricEsqPW.m"

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
cat > test_h_coef.ok << 'EOF'
h = [ -0.0005758002,  0.0161427573,  0.0340690973,  0.0368748501, ... 
       0.0093782715, -0.0365259914, -0.0571035289, -0.0058443604, ... 
       0.1213193850,  0.2661143766,  0.3400924385,  0.2903602787, ... 
       0.1443584234, -0.0077479883, -0.0813305882, -0.0586075660, ... 
       0.0080222090,  0.0488194732,  0.0350418677, -0.0073848969, ... 
      -0.0332496744, -0.0226376828,  0.0066247775,  0.0235513471, ... 
       0.0152629964, -0.0051530487, -0.0166387881, -0.0111820728, ... 
       0.0021376552,  0.0098737962,  0.0110995042 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_finsler_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

