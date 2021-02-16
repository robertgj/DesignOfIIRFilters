#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="directFIRnonsymmetric_kyp_bandpass_test.m test_common.m \
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
h = [ -0.0087719207, -0.0023879098,  0.0010558431, -0.0090280251, ... 
       0.0104023078,  0.0642054237,  0.0324436093, -0.1174488839, ... 
      -0.1535512920,  0.0689733489,  0.2530418674,  0.0819982556, ... 
      -0.2084821258, -0.1883052169,  0.0610041754,  0.1441974614, ... 
       0.0266123619, -0.0321021959,  0.0042338224, -0.0110459327, ... 
      -0.0542964980, -0.0175799373,  0.0436627488,  0.0320478756, ... 
      -0.0084219175, -0.0092890666,  0.0010258983, -0.0083908763, ... 
      -0.0105962315,  0.0038672770,  0.0100675127 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

