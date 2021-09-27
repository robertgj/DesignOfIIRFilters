#!/bin/sh

prog=tarczynski_frm_parallel_allpass_test.m
depends="tarczynski_frm_parallel_allpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m WISEJ_PA.m \
frm_lowpass_vectors.m"

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
cat > test_r_coef.m << 'EOF'
r = [   1.0000000000,   0.0396288473,   0.0689450149,  -0.0599083136, ... 
       -0.0443715393,   0.0464932638,   0.0083651274,  -0.0368797734, ... 
        0.0284772730 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m"; fail; fi

cat > test_s_coef.m << 'EOF'
s = [   1.0000000000,  -0.0379498063,  -0.0557882001,   0.0528952824, ... 
        0.0352025624,  -0.0329553363,   0.0030875737,   0.0226264664 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m"; fail; fi

cat > test_aa_coef.m << 'EOF'
aa = [   0.0076424576,  -0.0417429658,  -0.0106628464,   0.0396671843, ... 
         0.0028086783,  -0.0314888634,  -0.0071418990,   0.0354581562, ... 
         0.0226291197,  -0.0857253052,  -0.0310216299,   0.2845054093, ... 
         0.5515788988,   0.3465622603,  -0.0778338007,  -0.1050831922, ... 
         0.0755261114,   0.0355070001,  -0.0668385254,  -0.0029568447, ... 
         0.0575735174,  -0.0289068232,  -0.0385291943,   0.0530946516, ... 
         0.0360749411 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m"; fail; fi

cat > test_ac_coef.m << 'EOF'
ac = [   0.0134786578,   0.0119984894,   0.0035842663,  -0.0197834508, ... 
        -0.0027008664,   0.0339976984,  -0.0228718829,  -0.0317359446, ... 
         0.0679643778,  -0.0148035815,  -0.1235813661,   0.2794053585, ... 
         0.6495423962,   0.2857478392,  -0.1318730246,  -0.0130106994, ... 
         0.0689169107,  -0.0407520366,  -0.0145078078,   0.0420605919, ... 
        -0.0177122186,  -0.0186596970,   0.0235847343,  -0.0045626099, ... 
        -0.0083567689 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r_coef.m tarczynski_frm_parallel_allpass_test_r_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r_coef.m"; fail; fi

diff -Bb test_s_coef.m tarczynski_frm_parallel_allpass_test_s_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_s_coef.m"; fail; fi

diff -Bb test_aa_coef.m tarczynski_frm_parallel_allpass_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aa_coef.m"; fail; fi

diff -Bb test_ac_coef.m tarczynski_frm_parallel_allpass_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ac_coef.m"; fail; fi


#
# this much worked
#
pass

