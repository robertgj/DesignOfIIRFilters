#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_hilbert_test.m

depends="directFIRnonsymmetric_kyp_bandpass_hilbert_test.m test_common.m \
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
h = [  0.0016762658, -0.0123085996, -0.0036422584, -0.0030383700, ... 
      -0.0242071020, -0.0002533231,  0.0911242030,  0.0838850413, ... 
      -0.1118075866, -0.2222595369,  0.0001256200,  0.2675435617, ... 
       0.1622603995, -0.1479534355, -0.1973345486,  0.0002786941, ... 
       0.0847986836,  0.0172157095,  0.0126983646,  0.0544556963, ... 
      -0.0003986573, -0.0750320785, -0.0394175793,  0.0279886747, ... 
       0.0224533444,  0.0000846036,  0.0149977077,  0.0148662200, ... 
      -0.0168779780, -0.0237440925,  0.0001685185,  0.0092339636, ... 
       0.0012637105,  0.0019814148,  0.0057051806, -0.0001229696, ... 
      -0.0049705277, -0.0018420738,  0.0008265034, -0.0001270619, ... 
       0.0001748747 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_bandpass_hilbert_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

