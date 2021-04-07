#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="directFIRnonsymmetric_kyp_bandpass_test.m test_common.m \
direct_form_scale.m complementaryFIRlattice.m complementaryFIRlatticeAsq.m \
complementaryFIRlatticeT.m minphase.m complementaryFIRlattice2Abcd.m \
H2Asq.m H2T.m print_polynomial.m complementaryFIRlatticeFilter.m crossWelch.m \
complementaryFIRdecomp.oct Abcd2H.oct"

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
h = [ -0.0103309071, -0.0024159443,  0.0030905491, -0.0070637048, ... 
       0.0099297482,  0.0631106685,  0.0323281006, -0.1184996335, ... 
      -0.1552816729,  0.0706211650,  0.2575416357,  0.0832845513, ... 
      -0.2116740371, -0.1907371465,  0.0609807039,  0.1436887697, ... 
       0.0264317947, -0.0291922767,  0.0072526076, -0.0124057676, ... 
      -0.0578313044, -0.0187254373,  0.0442575543,  0.0320730586, ... 
      -0.0080020836, -0.0077761959,  0.0013596461, -0.0101905692, ... 
      -0.0122064076,  0.0037556903,  0.0106946813 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984300,  0.99993221,  0.99951439,  0.99901999, ... 
       0.99993824,  0.99897430,  0.99995309,  0.99998553, ... 
       0.99901522,  0.99976733,  0.98966438,  0.99765217, ... 
       0.99070621,  0.99162042,  0.99978173,  0.99979393, ... 
       0.99801390,  0.96858024,  0.91799668,  0.98572613, ... 
       0.80945614,  0.98758436,  0.92684286,  0.97094845, ... 
       0.99754038,  0.99612264,  0.99996900,  0.99995983, ... 
       0.99986687,  0.99995731, -0.01711660 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01771912, -0.01164368,  0.03116071,  0.04426126, ... 
       -0.01111420, -0.04528077, -0.00968550, -0.00537959, ... 
       -0.04436879,  0.02157066,  0.14340298,  0.06848467, ... 
       -0.13601913, -0.12918573,  0.02089236, -0.02030006, ... 
       -0.06299401,  0.24870126,  0.39658807, -0.16835676, ... 
       -0.58718034, -0.15708957,  0.37544948,  0.23928876, ... 
       -0.07009417, -0.08797546, -0.00787367, -0.00896268, ... 
       -0.01631684,  0.00924044,  0.99985350 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kc_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

diff -Bb test_k_coef.ok directFIRnonsymmetric_kyp_bandpass_test_k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_coef.m"; fail; fi

diff -Bb test_kc_coef.ok directFIRnonsymmetric_kyp_bandpass_test_kc_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_kc_coef.m"; fail; fi

#
# this much worked
#
pass

