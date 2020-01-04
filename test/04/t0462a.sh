#!/bin/sh

prog=selesnickFIRsymmetric_bandpass_test.m

depends="selesnickFIRsymmetric_bandpass_test.m test_common.m \
selesnickFIRsymmetric_bandpass.m selesnickFIRsymmetric_lowpass_exchange.m \
lagrange_interp.m print_polynomial.m local_max.m directFIRsymmetricA.m"

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
hM = [ -0.000000003709, -0.000679154064,  0.000061028012,  0.000909721968, ... 
        0.001058679255, -0.000161072642, -0.001686963375, -0.001777750687, ... 
       -0.000373261701,  0.000586957850, -0.000127087943, -0.000910683619, ... 
        0.000621699483,  0.003630570743,  0.004086914777, -0.000007482886, ... 
       -0.004974556572, -0.005372371085, -0.001201288421,  0.001735350326, ... 
       -0.000042823376, -0.002096052263,  0.001868290174,  0.009485588027, ... 
        0.010439264835, -0.000004768193, -0.012405709218, -0.013424438228, ... 
       -0.003277931867,  0.003976992327,  0.000053702058, -0.004612705733, ... 
        0.004680427045,  0.022453048789,  0.024665721802,  0.000011572193, ... 
       -0.029715202130, -0.032726885214, -0.008452976627,  0.009690216823, ... 
        0.000145095366, -0.012027445996,  0.013562668329,  0.067062275496, ... 
        0.079216145167,  0.000023284752, -0.120882185072, -0.162158878457, ... 
       -0.057660713592,  0.115644015202,  0.200182320035 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

