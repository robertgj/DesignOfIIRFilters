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
h = [ -0.0103310127, -0.0024160216,  0.0030905421, -0.0070636223, ... 
       0.0099298789,  0.0631108126,  0.0323281574, -0.1184997765, ... 
      -0.1552819422,  0.0706210002,  0.2575417225,  0.0832848226, ... 
      -0.2116737559, -0.1907370412,  0.0609805327,  0.1436884371, ... 
       0.0264315396, -0.0291922816,  0.0072528344, -0.0124054574, ... 
      -0.0578311278, -0.0187255316,  0.0442572887,  0.0320728432, ... 
      -0.0080021297, -0.0077760986,  0.0013598187, -0.0101904258, ... 
      -0.0122064094,  0.0037555734,  0.0106945538 ];
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

