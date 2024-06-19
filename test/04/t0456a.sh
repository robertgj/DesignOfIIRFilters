#!/bin/sh

prog=hofstetterFIRsymmetric_lowpass_test.m

depends="test/hofstetterFIRsymmetric_lowpass_test.m test_common.m \
print_polynomial.m hofstetterFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m qroots.m \
qzsolve.oct"

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
cat > test_hM.ok << 'EOF'
hM = [  -0.0000062744,  -0.0000244944,  -0.0000551827,  -0.0000819533, ... 
        -0.0000704428,   0.0000126058,   0.0001616955,   0.0003015039, ... 
         0.0003011099,   0.0000545772,  -0.0004030099,  -0.0008306872, ... 
        -0.0008611077,  -0.0002397438,   0.0008969019,   0.0019246655, ... 
         0.0019925489,   0.0005973054,  -0.0018561923,  -0.0039713247, ... 
        -0.0040237875,  -0.0011533299,   0.0036425566,   0.0075576337, ... 
         0.0074125952,   0.0018804923,  -0.0068946723,  -0.0136868237, ... 
        -0.0129477931,  -0.0026876364,   0.0129511570,   0.0246280536, ... 
         0.0226298007,   0.0034332146,  -0.0258331372,  -0.0483977600, ... 
        -0.0449658253,  -0.0039620478,   0.0704678795,   0.1575442544, ... 
         0.2274359299,   0.2541534897 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok hofstetterFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

