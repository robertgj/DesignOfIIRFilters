#!/bin/sh

prog=tarczynski_frm_parallel_allpass_test.m
depends="test/tarczynski_frm_parallel_allpass_test.m \
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
r = [   1.0000000000,   0.0396288383,   0.0689449146,  -0.0599083259, ... 
       -0.0443715190,   0.0464932403,   0.0083651217,  -0.0368797630, ... 
        0.0284772402 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m"; fail; fi

cat > test_s_coef.m << 'EOF'
s = [   1.0000000000,  -0.0379497906,  -0.0557881158,   0.0528953102, ... 
        0.0352025575,  -0.0329553367,   0.0030875766,   0.0226264982 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m"; fail; fi

cat > test_aa_coef.m << 'EOF'
aa = [   0.0076424788,  -0.0417429438,  -0.0106628632,   0.0396671868, ... 
         0.0028086779,  -0.0314888453,  -0.0071419290,   0.0354581654, ... 
         0.0226291376,  -0.0857253104,  -0.0310216240,   0.2845054157, ... 
         0.5515788970,   0.3465622534,  -0.0778337944,  -0.1050831794, ... 
         0.0755261034,   0.0355070158,  -0.0668385293,  -0.0029568322, ... 
         0.0575734952,  -0.0289067989,  -0.0385292011,   0.0530946347, ... 
         0.0360749511 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m"; fail; fi

cat > test_ac_coef.m << 'EOF'
ac = [   0.0134787120,   0.0119985410,   0.0035842287,  -0.0197834844, ... 
        -0.0027008390,   0.0339977416,  -0.0228719417,  -0.0317359549, ... 
         0.0679644297,  -0.0148035921,  -0.1235813976,   0.2794053706, ... 
         0.6495424184,   0.2857478421,  -0.1318730596,  -0.0130106779, ... 
         0.0689169341,  -0.0407520410,  -0.0145078563,   0.0420606155, ... 
        -0.0177121907,  -0.0186597135,   0.0235846925,  -0.0045625836, ... 
        -0.0083566943 ]';
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

