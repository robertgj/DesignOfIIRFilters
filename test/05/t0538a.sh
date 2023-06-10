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
h = [  0.0015935809, -0.0120587776, -0.0036005922, -0.0030830038, ... 
      -0.0242431895, -0.0002144011,  0.0910066219,  0.0837162569, ... 
      -0.1116380992, -0.2219363265,  0.0001039915,  0.2673296727, ... 
       0.1622600036, -0.1479569903, -0.1975717390,  0.0002445944, ... 
       0.0851728052,  0.0174312483,  0.0124957099,  0.0543031946, ... 
      -0.0003486052, -0.0751257647, -0.0395756994,  0.0281380962, ... 
       0.0227243005,  0.0000721936,  0.0148354535,  0.0148441739, ... 
      -0.0168641243, -0.0238193836,  0.0001563582,  0.0093371610, ... 
       0.0013167016,  0.0019432722,  0.0056828752, -0.0001188289, ... 
      -0.0049896792, -0.0018577820,  0.0008362556, -0.0001262961, ... 
       0.0001802538 ];
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

