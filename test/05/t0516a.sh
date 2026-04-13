#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_lowpass_test.m test_common.m delayz.m \
print_polynomial.m konopacki.m directFIRnonsymmetricEsqPW.m"

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
h = [ -0.0008739390,  0.0164442900,  0.0341368000,  0.0365350668, ... 
       0.0084233344, -0.0378225051, -0.0579627586, -0.0056518633, ... 
       0.1223673619,  0.2670302714,  0.3399960761,  0.2893248848, ... 
       0.1434325306, -0.0075528485, -0.0800716519, -0.0574367053, ... 
       0.0079436146,  0.0474643425,  0.0335722447, -0.0077203525, ... 
      -0.0322781123, -0.0213935569,  0.0069362430,  0.0226278910, ... 
       0.0139424865, -0.0057592496, -0.0160689652, -0.0099025070, ... 
       0.0033706535,  0.0105515619,  0.0110751643 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

