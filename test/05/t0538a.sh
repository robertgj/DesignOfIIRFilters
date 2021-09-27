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
h = [  0.0016451782, -0.0122146548, -0.0036268747, -0.0030544970, ... 
      -0.0242204356, -0.0002386386,  0.0910798809,  0.0838214135, ... 
      -0.1117444209, -0.2221385485,  0.0001179247,  0.2674641644, ... 
       0.1622607188, -0.1479548630, -0.1974239705,  0.0002650843, ... 
       0.0849382368,  0.0172966894,  0.0126233584,  0.0543993724, ... 
      -0.0003795999, -0.0750673624, -0.0394775891,  0.0280436221, ... 
       0.0225545127,  0.0000805980,  0.0149377517,  0.0148584072, ... 
      -0.0168726134, -0.0237724984,  0.0001632242,  0.0092719524, ... 
       0.0012836263,  0.0019676242,  0.0056971651, -0.0001212541, ... 
      -0.0049776164, -0.0018481084,  0.0008297249, -0.0001270555, ... 
       0.0001768761 ];
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

