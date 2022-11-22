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
r = [   1.0000000000,   0.0396288346,   0.0689449038,  -0.0599083253, ... 
       -0.0443715176,   0.0464932379,   0.0083651222,  -0.0368797617, ... 
        0.0284772383 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m"; fail; fi

cat > test_s_coef.m << 'EOF'
s = [   1.0000000000,  -0.0379497873,  -0.0557881122,   0.0528953102, ... 
        0.0352025559,  -0.0329553378,   0.0030875757,   0.0226265002 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m"; fail; fi

cat > test_aa_coef.m << 'EOF'
aa = [   0.0076424795,  -0.0417429438,  -0.0106628630,   0.0396671852, ... 
         0.0028086778,  -0.0314888444,  -0.0071419297,   0.0354581665, ... 
         0.0226291379,  -0.0857253098,  -0.0310216245,   0.2845054151, ... 
         0.5515788943,   0.3465622537,  -0.0778337923,  -0.1050831790, ... 
         0.0755261020,   0.0355070146,  -0.0668385295,  -0.0029568308, ... 
         0.0575734938,  -0.0289067969,  -0.0385292015,   0.0530946344, ... 
         0.0360749530 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m"; fail; fi

cat > test_ac_coef.m << 'EOF'
ac = [   0.0134787163,   0.0119985458,   0.0035842262,  -0.0197834896, ... 
        -0.0027008351,   0.0339977450,  -0.0228719460,  -0.0317359545, ... 
         0.0679644351,  -0.0148035935,  -0.1235813996,   0.2794053704, ... 
         0.6495424170,   0.2857478412,  -0.1318730595,  -0.0130106788, ... 
         0.0689169351,  -0.0407520403,  -0.0145078607,   0.0420606160, ... 
        -0.0177121863,  -0.0186597154,   0.0235846881,  -0.0045625813, ... 
        -0.0083566877 ]';
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

