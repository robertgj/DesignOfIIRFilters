#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_hilbert_test.m

depends="test/directFIRnonsymmetric_kyp_bandpass_hilbert_test.m test_common.m \
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
h = [  0.0015935921, -0.0120587582, -0.0036006086, -0.0030830178, ... 
      -0.0242431773, -0.0002144184,  0.0910065886,  0.0837163017, ... 
      -0.1116380204, -0.2219363484,  0.0001039221,  0.2673296811, ... 
       0.1622600077, -0.1479570676, -0.1975717323,  0.0002447442, ... 
       0.0851728602,  0.0174311347,  0.0124956558,  0.0543032340, ... 
      -0.0003486571, -0.0751258312, -0.0395755845,  0.0281382372, ... 
       0.0227242414,  0.0000720815,  0.0148354679,  0.0148441836, ... 
      -0.0168641944, -0.0238193638,  0.0001564818,  0.0093371867, ... 
       0.0013166164,  0.0019432411,  0.0056828996, -0.0001188467, ... 
      -0.0049896992, -0.0018577427,  0.0008362878, -0.0001263198, ... 
       0.0001802344 ];
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

