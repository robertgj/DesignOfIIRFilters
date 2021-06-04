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
h = [  0.0016454403, -0.0122147510, -0.0036266663, -0.0030547083, ... 
      -0.0242208745, -0.0002388443,  0.0910801648,  0.0838217981, ... 
      -0.1117440041, -0.2221380645,  0.0001177553,  0.2674630318, ... 
       0.1622598091, -0.1479546376, -0.1974232525,  0.0002657784, ... 
       0.0849390988,  0.0172969784,  0.0126221626,  0.0543978229, ... 
      -0.0003798579, -0.0750667062, -0.0394769082,  0.0280445812, ... 
       0.0225553475,  0.0000799873,  0.0149361632,  0.0148577143, ... 
      -0.0168722264, -0.0237720704,  0.0001637508,  0.0092727599, ... 
       0.0012837353,  0.0019667257,  0.0056964576, -0.0001211745, ... 
      -0.0049773742, -0.0018479869,  0.0008299477, -0.0001265722, ... 
       0.0001764576 ];
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

