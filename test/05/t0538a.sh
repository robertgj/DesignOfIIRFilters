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
h = [ -0.0127146173, -0.0191040860, -0.0040567407,  0.0004849061, ... 
      -0.0190137660, -0.0296052659,  0.0007599363,  0.0427211671, ... 
       0.0386150900,  0.0023297242,  0.0144007853,  0.0824139300, ... 
       0.0848498042, -0.0637098664, -0.2415672316, -0.2299134378, ... 
       0.0011219802,  0.2261291563,  0.2312887763,  0.0606400356, ... 
      -0.0759201763, -0.0743622027, -0.0168304715, -0.0066312703, ... 
      -0.0337900494, -0.0342119356, -0.0006717838,  0.0240232077, ... 
       0.0201910556, -0.0043241207,  0.0118776567 ];
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

