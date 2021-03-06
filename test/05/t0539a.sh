#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m \
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
cat > test_h_coef.ok << 'EOF'
h = [ -0.0000863523,  0.0045206132, -0.0246969210, -0.0013919811, ... 
      -0.0211041376, -0.0523630302, -0.0170485651,  0.0333693958, ... 
       0.0123629953,  0.0125937082,  0.0684991952,  0.0355248212, ... 
      -0.1461938723, -0.1759362549,  0.0727691803,  0.3676635449, ... 
       0.0714859781, -0.1845287909, -0.1622510624,  0.0144241539, ... 
       0.0457789912, -0.0125216105,  0.0003160229,  0.0380468816, ... 
       0.0012403299, -0.0417196109,  0.0266502549, -0.0064237742, ... 
       0.0005978147, -0.0000131725,  0.0000001173 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

