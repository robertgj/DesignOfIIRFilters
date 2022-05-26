#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m \
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
h = [ -0.0000863536,  0.0045206514, -0.0246970128, -0.0013927864, ... 
      -0.0211035218, -0.0523641214, -0.0170485311,  0.0333698035, ... 
       0.0123636532,  0.0125932183,  0.0685008238,  0.0355249100, ... 
      -0.1461948601, -0.1759365802,  0.0727690680,  0.3676607794, ... 
       0.0714861380, -0.1845297421, -0.1622513002,  0.0144234157, ... 
       0.0457802681, -0.0125225388,  0.0003169245,  0.0380461241, ... 
       0.0012412903, -0.0417205380,  0.0266507435, -0.0064239148, ... 
       0.0005978355, -0.0000131737,  0.0000001173 ];
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

