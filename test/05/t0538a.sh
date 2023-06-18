#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_hilbert_test.m

depends="test/directFIRnonsymmetric_kyp_bandpass_hilbert_test.m test_common.m delayz.m \
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
h = [  0.0015805498, -0.0120066884, -0.0035827587, -0.0030951814, ... 
      -0.0242644072, -0.0002086174,  0.0909872565,  0.0836755824, ... 
      -0.1115995219, -0.2218415718,  0.0001074005,  0.2672488756, ... 
       0.1622363410, -0.1479375956, -0.1976107417,  0.0002255810, ... 
       0.0852731996,  0.0175125952,  0.0124236579,  0.0542103352, ... 
      -0.0003322636, -0.0751000458, -0.0396066354,  0.0281585726, ... 
       0.0228068395,  0.0000754434,  0.0147524619,  0.0148131467, ... 
      -0.0168256666, -0.0238054300,  0.0001435084,  0.0093521191, ... 
       0.0013350321,  0.0019242884,  0.0056596380, -0.0001113898, ... 
      -0.0049750072, -0.0018590103,  0.0008309413, -0.0001250316, ... 
       0.0001739622 ];
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

