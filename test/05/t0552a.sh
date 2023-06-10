#!/bin/sh

prog=tarczynski_frm_iir_test.m

depends="test/tarczynski_frm_iir_test.m test_common.m delayz.m print_polynomial.m \
print_pole_zero.m frm_lowpass_vectors.m"

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
cat > test_a.ok << 'EOF'
x0.a = [   0.0565615299,   0.0099594192,  -0.0900439987,   0.0029955464, ... 
           0.2826218588,   0.5198093664,   0.2992207295,   0.0031561218, ... 
          -0.0956647864,   0.0368328664,   0.0350866645 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a.ok"; fail; fi

cat > test_d.ok << 'EOF'
x0.d = [   1.0000000000,   0.0045472048,  -0.0074361530,  -0.0095229364, ... 
          -0.0054180876,   0.0022465447,   0.0042617002,   0.0026666508, ... 
          -0.0001906551,  -0.0011727890,   0.0001506487 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d.ok"; fail; fi

cat > test_aa.ok << 'EOF'
x0.aa = [   0.0159132284,  -0.0053493630,  -0.0098654877,   0.0090780946, ... 
            0.0023043235,  -0.0050293145,   0.0028686187,  -0.0052320591, ... 
            0.0059260524,   0.0016106461,  -0.0098886954,  -0.0029137921, ... 
            0.0182774213,   0.0038255907,  -0.0360602740,   0.0161249658, ... 
            0.0593386751,  -0.0761064618,  -0.0692775649,   0.3092898981, ... 
            0.5701401435,   0.3092898981,  -0.0692775649,  -0.0761064618, ... 
            0.0593386751,   0.0161249658,  -0.0360602740,   0.0038255907, ... 
            0.0182774213,  -0.0029137921,  -0.0098886954,   0.0016106461, ... 
            0.0059260524,  -0.0052320591,   0.0028686187,  -0.0050293145, ... 
            0.0023043235,   0.0090780946,  -0.0098654877,  -0.0053493630, ... 
            0.0159132284 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa.ok"; fail; fi

cat > test_ac.ok << 'EOF'
x0.ac = [  -0.0249619213,  -0.0299042179,   0.0194400692,   0.0245372301, ... 
           -0.0243177360,  -0.0117173649,   0.0287901882,  -0.0054289906, ... 
           -0.0244408005,   0.0226354226,   0.0099626491,  -0.0327675729, ... 
            0.0142856456,   0.0282396044,  -0.0472859493,  -0.0037781444, ... 
            0.0757810758,  -0.0593773565,  -0.1021436780,   0.3077984889, ... 
            0.6218858244,   0.3077984889,  -0.1021436780,  -0.0593773565, ... 
            0.0757810758,  -0.0037781444,  -0.0472859493,   0.0282396044, ... 
            0.0142856456,  -0.0327675729,   0.0099626491,   0.0226354226, ... 
           -0.0244408005,  -0.0054289906,   0.0287901882,  -0.0117173649, ... 
           -0.0243177360,   0.0245372301,   0.0194400692,  -0.0299042179, ... 
           -0.0249619213 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a.ok tarczynski_frm_iir_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a.ok"; fail; fi

diff -Bb test_d.ok tarczynski_frm_iir_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d.ok"; fail; fi

diff -Bb test_aa.ok tarczynski_frm_iir_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aa.ok"; fail; fi

diff -Bb test_ac.ok tarczynski_frm_iir_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ac.ok"; fail; fi


#
# this much worked
#
pass

