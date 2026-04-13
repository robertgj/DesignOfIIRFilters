#!/bin/sh

prog=tarczynski_frm_parallel_allpass_test.m
depends="test/tarczynski_frm_parallel_allpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m WISEJ_PA.m \
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
r = [   1.0000000000,   0.0396288448,   0.0689449828,  -0.0599083191, ... 
       -0.0443715359,   0.0464932577,   0.0083651244,  -0.0368797729, ... 
        0.0284772641 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m"; fail; fi

cat > test_s_coef.m << 'EOF'
s = [   1.0000000000,  -0.0379498021,  -0.0557881735,   0.0528952923, ... 
        0.0352025611,  -0.0329553371,   0.0030875757,   0.0226264781 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m"; fail; fi

cat > test_aa_coef.m << 'EOF'
aa = [   0.0076424647,  -0.0417429584,  -0.0106628531,   0.0396671882, ... 
         0.0028086759,  -0.0314888575,  -0.0071419093,   0.0354581593, ... 
         0.0226291274,  -0.0857253092,  -0.0310216262,   0.2845054097, ... 
         0.5515788991,   0.3465622590,  -0.0778337995,  -0.1050831870, ... 
         0.0755261094,   0.0355070049,  -0.0668385279,  -0.0029568407, ... 
         0.0575735112,  -0.0289068160,  -0.0385291982,   0.0530946472, ... 
         0.0360749463 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m"; fail; fi

cat > test_ac_coef.m << 'EOF'
ac = [   0.0134786764,   0.0119985054,   0.0035842540,  -0.0197834608, ... 
        -0.0027008598,   0.0339977144,  -0.0228719006,  -0.0317359498, ... 
         0.0679643938,  -0.0148035826,  -0.1235813776,   0.2794053631, ... 
         0.6495424046,   0.2857478424,  -0.1318730406,  -0.0130106911, ... 
         0.0689169190,  -0.0407520406,  -0.0145078229,   0.0420606024, ... 
        -0.0177122123,  -0.0186597042,   0.0235847241,  -0.0045626022, ... 
        -0.0083567466 ]';
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

