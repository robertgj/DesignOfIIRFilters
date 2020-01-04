#!/bin/sh

prog=mcclellanFIRsymmetric_lowpass_test.m

depends="mcclellanFIRsymmetric_lowpass_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
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
cat > test_hM.ok << 'EOF'
hM = [  -0.0033554474,  -0.0060206464,  -0.0008106870,   0.0097507927, ... 
         0.0083169067,  -0.0113360291,  -0.0218303021,   0.0048220280, ... 
         0.0398898607,   0.0177625604,  -0.0583642414,  -0.0735976811, ... 
         0.0724112343,   0.3065830768,   0.4224251607 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

