#!/bin/sh

prog=directFIRsymmetric_kyp_lowpass_test.m
depends="test/directFIRsymmetric_kyp_lowpass_test.m \
test_common.m print_polynomial.m directFIRsymmetricEsqPW.m \
mcclellanFIRsymmetric.m local_max.m lagrange_interp.m xfr2tf.m \
directFIRsymmetricA.m"

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
h = [ -0.0016663125, -0.0005569569,  0.0015609653,  0.0026312600, ... 
       0.0006608913, -0.0030961277, -0.0042912485, -0.0002069004, ... 
       0.0057854413,  0.0064118212, -0.0011565221, -0.0099072345, ... 
      -0.0088172400,  0.0040467024,  0.0159839114,  0.0112961708, ... 
      -0.0095006723, -0.0250744643, -0.0136006681,  0.0197719320, ... 
       0.0400835388,  0.0154766519, -0.0421443472, -0.0730442956, ... 
      -0.0166990048,  0.1272992063,  0.2831703033,  0.3504662325, ... 
       0.2831703033,  0.1272992063, -0.0166990048, -0.0730442956, ... 
      -0.0421443472,  0.0154766519,  0.0400835388,  0.0197719320, ... 
      -0.0136006681, -0.0250744643, -0.0095006723,  0.0112961708, ... 
       0.0159839114,  0.0040467024, -0.0088172400, -0.0099072345, ... 
      -0.0011565221,  0.0064118212,  0.0057854413, -0.0002069004, ... 
      -0.0042912485, -0.0030961277,  0.0006608913,  0.0026312600, ... 
       0.0015609653, -0.0005569569, -0.0016663125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass
