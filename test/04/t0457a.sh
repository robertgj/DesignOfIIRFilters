#!/bin/sh

prog=hofstetterFIRsymmetric_bandpass_test.m

depends="hofstetterFIRsymmetric_bandpass_test.m test_common.m \
print_polynomial.m hofstetterFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m"

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
hM = [   0.0016403235,   0.0003811934,  -0.0031154274,  -0.0014736974, ... 
         0.0041494943,   0.0026338117,  -0.0033919821,  -0.0021854812, ... 
         0.0005763605,  -0.0018192528,   0.0028371388,   0.0098604875, ... 
        -0.0041768995,  -0.0193489621,   0.0016309399,   0.0246939527, ... 
         0.0032233259,  -0.0198235341,  -0.0044329061,   0.0022230559, ... 
        -0.0062571008,   0.0239834184,   0.0346597112,  -0.0484236390, ... 
        -0.0792843518,   0.0589851401,   0.1296762482,  -0.0483396210, ... 
        -0.1697773982,   0.0186531279,   0.1850850479 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok hofstetterFIRsymmetric_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

