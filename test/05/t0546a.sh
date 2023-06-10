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
r = [   1.0000000000,   0.0396288337,   0.0689448888,  -0.0599083300, ... 
       -0.0443715159,   0.0464932335,   0.0083651224,  -0.0368797604, ... 
        0.0284772340 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m"; fail; fi

cat > test_s_coef.m << 'EOF'
s = [   1.0000000000,  -0.0379497855,  -0.0557880998,   0.0528953135, ... 
        0.0352025558,  -0.0329553387,   0.0030875774,   0.0226265063 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m"; fail; fi

cat > test_aa_coef.m << 'EOF'
aa = [   0.0076424822,  -0.0417429393,  -0.0106628658,   0.0396671854, ... 
         0.0028086756,  -0.0314888406,  -0.0071419328,   0.0354581675, ... 
         0.0226291393,  -0.0857253112,  -0.0310216208,   0.2845054152, ... 
         0.5515788927,   0.3465622521,  -0.0778337900,  -0.1050831759, ... 
         0.0755261010,   0.0355070185,  -0.0668385315,  -0.0029568302, ... 
         0.0575734911,  -0.0289067920,  -0.0385292002,   0.0530946309, ... 
         0.0360749542 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m"; fail; fi

cat > test_ac_coef.m << 'EOF'
ac = [   0.0134787249,   0.0119985544,   0.0035842220,  -0.0197834938, ... 
        -0.0027008322,   0.0339977518,  -0.0228719559,  -0.0317359563, ... 
         0.0679644432,  -0.0148035937,  -0.1235814042,   0.2794053724, ... 
         0.6495424195,   0.2857478409,  -0.1318730660,  -0.0130106740, ... 
         0.0689169395,  -0.0407520416,  -0.0145078665,   0.0420606217, ... 
        -0.0177121830,  -0.0186597176,   0.0235846828,  -0.0045625763, ... 
        -0.0083566771 ]';
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

