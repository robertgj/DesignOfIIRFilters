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
h = [ -0.0103310242, -0.0024158430,  0.0030906630, -0.0070639234, ... 
       0.0099294830,  0.0631107470,  0.0323281562, -0.1184998735, ... 
      -0.1552816116,  0.0706216712,  0.2575416442,  0.0832838643, ... 
      -0.2116742994, -0.1907367590,  0.0609807654,  0.1436885397, ... 
       0.0264321213, -0.0291918402,  0.0072521867, -0.0124064259, ... 
      -0.0578311706, -0.0187250333,  0.0442574756,  0.0320729627, ... 
      -0.0080018109, -0.0077761515,  0.0013592394, -0.0101907755, ... 
      -0.0122061971,  0.0037558161,  0.0106945580 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984301,  0.99993221,  0.99951441,  0.99901998, ... 
       0.99993825,  0.99897433,  0.99995307,  0.99998552, ... 
       0.99901529,  0.99976727,  0.98966443,  0.99765228, ... 
       0.99070625,  0.99162048,  0.99978176,  0.99979392, ... 
       0.99801406,  0.96857970,  0.91799740,  0.98572567, ... 
       0.80945640,  0.98758466,  0.92684266,  0.97094863, ... 
       0.99754032,  0.99612265,  0.99996901,  0.99995984, ... 
       0.99986687,  0.99995731, -0.01711678 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01771890, -0.01164384,  0.03116005,  0.04426146, ... 
       -0.01111259, -0.04528017, -0.00968760, -0.00538150, ... 
       -0.04436732,  0.02157315,  0.14340267,  0.06848312, ... 
       -0.13601882, -0.12918525,  0.02089078, -0.02030085, ... 
       -0.06299149,  0.24870338,  0.39658640, -0.16835946, ... 
       -0.58717998, -0.15708765,  0.37544998,  0.23928802, ... 
       -0.07009496, -0.08797532, -0.00787297, -0.00896246, ... 
       -0.01631714,  0.00924035,  0.99985350 ]';
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

