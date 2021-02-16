#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="directFIRnonsymmetric_kyp_lowpass_test.m test_common.m \
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
h = [ -0.0051265021,  0.0016175177,  0.0105219803,  0.0112679516, ... 
      -0.0056422723, -0.0322885625, -0.0380873962,  0.0111538169, ... 
       0.1199640324,  0.2452471030,  0.3165455324,  0.2850385994, ... 
       0.1633589480,  0.0200527495, -0.0687888254, -0.0723906068, ... 
      -0.0200215870,  0.0308005828,  0.0417346601,  0.0166222841, ... 
      -0.0135491195, -0.0232109906, -0.0113637927,  0.0051353433, ... 
       0.0113227829,  0.0060896064, -0.0017160091, -0.0045556794, ... 
      -0.0022753072,  0.0007317681,  0.0013737808 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

