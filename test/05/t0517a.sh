#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_bandpass_test.m test_common.m delayz.m \
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
h = [ -0.0104143949, -0.0023682483,  0.0032719791, -0.0069032395, ... 
       0.0099100648,  0.0630395379,  0.0323190391, -0.1185517528, ... 
      -0.1553404297,  0.0708049785,  0.2578895336,  0.0833677118, ... 
      -0.2119296948, -0.1909550140,  0.0609505534,  0.1436758056, ... 
       0.0264655996, -0.0289757088,  0.0074300619, -0.0125615250, ... 
      -0.0581536028, -0.0188770460,  0.0442642640,  0.0320711422, ... 
      -0.0079897003, -0.0077190647,  0.0013262161, -0.0103678247, ... 
      -0.0123694529,  0.0037079875,  0.0107180320 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984130,  0.99993213,  0.99949924,  0.99898912, ... 
       0.99993604,  0.99892181,  0.99994837,  0.99999003, ... 
       0.99905269,  0.99976686,  0.98961334,  0.99761968, ... 
       0.99052500,  0.99134934,  0.99977155,  0.99984184, ... 
       0.99807139,  0.96873149,  0.91782544,  0.98563404, ... 
       0.80792756,  0.98751343,  0.92625402,  0.97087760, ... 
       0.99752953,  0.99617962,  0.99997130,  0.99995415, ... 
       0.99985791,  0.99995704, -0.01731041 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01781495, -0.01165050,  0.03164275,  0.04495269, ... 
       -0.01131020, -0.04642426, -0.01016108, -0.00446454, ... 
       -0.04351701,  0.02159226,  0.14375481,  0.06895637, ... 
       -0.13733253, -0.13124968,  0.02137398, -0.01778461, ... 
       -0.06207655,  0.24811145,  0.39698420, -0.16889507, ... 
       -0.58928181, -0.15753485,  0.37689985,  0.23957604, ... 
       -0.07024833, -0.08732797, -0.00757643, -0.00957607, ... 
       -0.01685723,  0.00926906,  0.99985016 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kc_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

