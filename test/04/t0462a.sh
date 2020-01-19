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
hM = [ -0.000000003746, -0.000679210223,  0.000060806040,  0.000909263306, ... 
        0.001057903026, -0.000162163864, -0.001688358425, -0.001779376885, ... 
       -0.000375042896,  0.000585147902, -0.000128856814, -0.000912385438, ... 
        0.000619984199,  0.003628765855,  0.004084943906, -0.000009617547, ... 
       -0.004976845888, -0.005374741565, -0.001203653798,  0.001733131712, ... 
       -0.000044821059, -0.002097823935,  0.001866620306,  0.009483892663, ... 
        0.010437422717, -0.000006789610, -0.012407924887, -0.013426785903, ... 
       -0.003280323264,  0.003974710330,  0.000051619839, -0.004614563214, ... 
        0.004678693307,  0.022451332242,  0.024663909992,  0.000009625911, ... 
       -0.029717315933, -0.032729129740, -0.008455296635,  0.009687938549, ... 
        0.000142928925, -0.012029459285,  0.013560760236,  0.067060429395, ... 
        0.079214291488,  0.000021395925, -0.120884155077, -0.162160927767, ... 
       -0.057662847420,  0.115641839519,  0.200180120388 ]';
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

