#!/bin/sh

prog=tarczynski_frm_iir_test.m

depends="tarczynski_frm_iir_test.m test_common.m print_polynomial.m \
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
x0.a = [   0.0565615293,   0.0099594168,  -0.0900439969,   0.0029955475, ... 
           0.2826218565,   0.5198093681,   0.2992207273,   0.0031561216, ... 
          -0.0956647864,   0.0368328695,   0.0350866628 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a.ok"; fail; fi

cat > test_d.ok << 'EOF'
x0.d = [   1.0000000000,   0.0045472050,  -0.0074361515,  -0.0095229355, ... 
          -0.0054180888,   0.0022465446,   0.0042617013,   0.0026666507, ... 
          -0.0001906550,  -0.0011727890,   0.0001506475 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d.ok"; fail; fi

cat > test_aa.ok << 'EOF'
x0.aa = [   0.0159132276,  -0.0053493649,  -0.0098654866,   0.0090780954, ... 
            0.0023043231,  -0.0050293157,   0.0028686191,  -0.0052320575, ... 
            0.0059260531,   0.0016106453,  -0.0098886949,  -0.0029137907, ... 
            0.0182774198,   0.0038255903,  -0.0360602730,   0.0161249646, ... 
            0.0593386747,  -0.0761064639,  -0.0692775633,   0.3092898994, ... 
            0.5701401409,   0.3092898994,  -0.0692775633,  -0.0761064639, ... 
            0.0593386747,   0.0161249646,  -0.0360602730,   0.0038255903, ... 
            0.0182774198,  -0.0029137907,  -0.0098886949,   0.0016106453, ... 
            0.0059260531,  -0.0052320575,   0.0028686191,  -0.0050293157, ... 
            0.0023043231,   0.0090780954,  -0.0098654866,  -0.0053493649, ... 
            0.0159132276 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa.ok"; fail; fi

cat > test_ac.ok << 'EOF'
x0.ac = [  -0.0249619220,  -0.0299042185,   0.0194400696,   0.0245372314, ... 
           -0.0243177367,  -0.0117173674,   0.0287901885,  -0.0054289912, ... 
           -0.0244408014,   0.0226354220,   0.0099626494,  -0.0327675721, ... 
            0.0142856442,   0.0282396024,  -0.0472859486,  -0.0037781427, ... 
            0.0757810749,  -0.0593773564,  -0.1021436786,   0.3077984881, ... 
            0.6218858248,   0.3077984881,  -0.1021436786,  -0.0593773564, ... 
            0.0757810749,  -0.0037781427,  -0.0472859486,   0.0282396024, ... 
            0.0142856442,  -0.0327675721,   0.0099626494,   0.0226354220, ... 
           -0.0244408014,  -0.0054289912,   0.0287901885,  -0.0117173674, ... 
           -0.0243177367,   0.0245372314,   0.0194400696,  -0.0299042185, ... 
           -0.0249619220 ]';
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

