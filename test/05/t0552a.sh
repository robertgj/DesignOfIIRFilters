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
x0.a = [   0.0565615313,   0.0099594170,  -0.0900439979,   0.0029955476, ... 
           0.2826218570,   0.5198093687,   0.2992207282,   0.0031561223, ... 
          -0.0956647862,   0.0368328708,   0.0350866630 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a.ok"; fail; fi

cat > test_d.ok << 'EOF'
x0.d = [   1.0000000000,   0.0045472056,  -0.0074361526,  -0.0095229363, ... 
          -0.0054180899,   0.0022465458,   0.0042617004,   0.0026666510, ... 
          -0.0001906567,  -0.0011727904,   0.0001506489 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d.ok"; fail; fi

cat > test_aa.ok << 'EOF'
x0.aa = [   0.0159132285,  -0.0053493640,  -0.0098654873,   0.0090780946, ... 
            0.0023043230,  -0.0050293157,   0.0028686184,  -0.0052320599, ... 
            0.0059260537,   0.0016106453,  -0.0098886958,  -0.0029137914, ... 
            0.0182774203,   0.0038255911,  -0.0360602730,   0.0161249641, ... 
            0.0593386774,  -0.0761064638,  -0.0692775639,   0.3092898997, ... 
            0.5701401425,   0.3092898997,  -0.0692775639,  -0.0761064638, ... 
            0.0593386774,   0.0161249641,  -0.0360602730,   0.0038255911, ... 
            0.0182774203,  -0.0029137914,  -0.0098886958,   0.0016106453, ... 
            0.0059260537,  -0.0052320599,   0.0028686184,  -0.0050293157, ... 
            0.0023043230,   0.0090780946,  -0.0098654873,  -0.0053493640, ... 
            0.0159132285 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa.ok"; fail; fi

cat > test_ac.ok << 'EOF'
x0.ac = [  -0.0249619215,  -0.0299042190,   0.0194400697,   0.0245372313, ... 
           -0.0243177365,  -0.0117173671,   0.0287901895,  -0.0054289904, ... 
           -0.0244408002,   0.0226354217,   0.0099626483,  -0.0327675716, ... 
            0.0142856459,   0.0282396027,  -0.0472859492,  -0.0037781424, ... 
            0.0757810748,  -0.0593773568,  -0.1021436798,   0.3077984878, ... 
            0.6218858249,   0.3077984878,  -0.1021436798,  -0.0593773568, ... 
            0.0757810748,  -0.0037781424,  -0.0472859492,   0.0282396027, ... 
            0.0142856459,  -0.0327675716,   0.0099626483,   0.0226354217, ... 
           -0.0244408002,  -0.0054289904,   0.0287901895,  -0.0117173671, ... 
           -0.0243177365,   0.0245372313,   0.0194400697,  -0.0299042190, ... 
           -0.0249619215 ]';
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

