#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_lowpass_test.m test_common.m \
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
h = [ -0.0008739276,  0.0164442882,  0.0341367694,  0.0365350349, ... 
       0.0084233139, -0.0378225020, -0.0579627433, -0.0056518581, ... 
       0.1223673481,  0.2670302513,  0.3399960650,  0.2893249030, ... 
       0.1434325420, -0.0075528416, -0.0800716777, -0.0574367175, ... 
       0.0079436085,  0.0474643687,  0.0335722577, -0.0077203498, ... 
      -0.0322781337, -0.0213935677,  0.0069362515,  0.0226279113, ... 
       0.0139424991, -0.0057592565, -0.0160689810, -0.0099025093, ... 
       0.0033706727,  0.0105515982,  0.0110751954 ];
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

