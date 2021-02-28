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
h = [ -0.0018428578,  0.0152712616,  0.0325003701,  0.0351349882, ... 
       0.0075272412, -0.0384315022, -0.0588243950, -0.0071587425, ... 
       0.1203301754,  0.2649889695,  0.3384334053,  0.2883209607, ... 
       0.1427143202, -0.0082550025, -0.0807839132, -0.0580531396, ... 
       0.0073783463,  0.0466807147,  0.0323412896, -0.0092630392, ... 
      -0.0336345875, -0.0220827004,  0.0069604848,  0.0229330696, ... 
       0.0139768329, -0.0062389605, -0.0168753396, -0.0106548806, ... 
       0.0029303828,  0.0104570284,  0.0110484673 ];
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

