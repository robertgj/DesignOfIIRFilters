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
h = [ -0.0016762563,  0.0123087217,  0.0036417209,  0.0030384652, ... 
       0.0242075557,  0.0002531179, -0.0911247091, -0.0838844537, ... 
       0.1118081627,  0.2222585285, -0.0001263414, -0.2675424062, ... 
      -0.1622598609,  0.1479521485,  0.1973345220, -0.0002769970, ... 
      -0.0847989720, -0.0172176826, -0.0126980030, -0.0544540218, ... 
       0.0003979119,  0.0750308601,  0.0394190254, -0.0279875163, ... 
      -0.0224550804, -0.0000857386, -0.0149962694, -0.0148656334, ... 
       0.0168767469,  0.0237442093, -0.0001671521, -0.0092342966, ... 
      -0.0012650234, -0.0019811929, -0.0057043337,  0.0001226941, ... 
       0.0049701100,  0.0018425247, -0.0008261710,  0.0001263705, ... 
      -0.0001747881 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_bandpass_hilbert_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

