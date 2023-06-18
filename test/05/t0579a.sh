#!/bin/sh

prog=directFIRsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRsymmetric_kyp_union_bandpass_test.m test_common.m \
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
h = [ -0.0034839695, -0.0003592293, -0.0043641593, -0.0112517525, ... 
       0.0043018203,  0.0105170057, -0.0028407625,  0.0292538842, ... 
       0.0492568177, -0.0166214335, -0.0188211131,  0.0207530855, ... 
      -0.1441413531, -0.2431499798,  0.1187484767,  0.4225485257, ... 
       0.1187484767, -0.2431499798, -0.1441413531,  0.0207530855, ... 
      -0.0188211131, -0.0166214335,  0.0492568177,  0.0292538842, ... 
      -0.0028407625,  0.0105170057,  0.0043018203, -0.0112517525, ... 
      -0.0043641593, -0.0003592293, -0.0034839695 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

