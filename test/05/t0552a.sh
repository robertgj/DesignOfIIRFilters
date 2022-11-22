#!/bin/sh

prog=tarczynski_frm_iir_test.m

depends="test/tarczynski_frm_iir_test.m test_common.m print_polynomial.m \
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
x0.a = [   0.0565615300,   0.0099594179,  -0.0900439989,   0.0029955472, ... 
           0.2826218580,   0.5198093671,   0.2992207306,   0.0031561221, ... 
          -0.0956647860,   0.0368328675,   0.0350866644 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a.ok"; fail; fi

cat > test_d.ok << 'EOF'
x0.d = [   1.0000000000,   0.0045472050,  -0.0074361536,  -0.0095229356, ... 
          -0.0054180893,   0.0022465464,   0.0042617007,   0.0026666523, ... 
          -0.0001906559,  -0.0011727896,   0.0001506486 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d.ok"; fail; fi

cat > test_aa.ok << 'EOF'
x0.aa = [   0.0159132282,  -0.0053493642,  -0.0098654874,   0.0090780940, ... 
            0.0023043234,  -0.0050293148,   0.0028686184,  -0.0052320599, ... 
            0.0059260532,   0.0016106458,  -0.0098886952,  -0.0029137930, ... 
            0.0182774206,   0.0038255903,  -0.0360602734,   0.0161249650, ... 
            0.0593386755,  -0.0761064625,  -0.0692775643,   0.3092898982, ... 
            0.5701401433,   0.3092898982,  -0.0692775643,  -0.0761064625, ... 
            0.0593386755,   0.0161249650,  -0.0360602734,   0.0038255903, ... 
            0.0182774206,  -0.0029137930,  -0.0098886952,   0.0016106458, ... 
            0.0059260532,  -0.0052320599,   0.0028686184,  -0.0050293148, ... 
            0.0023043234,   0.0090780940,  -0.0098654874,  -0.0053493642, ... 
            0.0159132282 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa.ok"; fail; fi

cat > test_ac.ok << 'EOF'
x0.ac = [  -0.0249619216,  -0.0299042181,   0.0194400686,   0.0245372299, ... 
           -0.0243177365,  -0.0117173661,   0.0287901880,  -0.0054289910, ... 
           -0.0244408014,   0.0226354218,   0.0099626486,  -0.0327675728, ... 
            0.0142856452,   0.0282396037,  -0.0472859498,  -0.0037781435, ... 
            0.0757810765,  -0.0593773564,  -0.1021436777,   0.3077984884, ... 
            0.6218858243,   0.3077984884,  -0.1021436777,  -0.0593773564, ... 
            0.0757810765,  -0.0037781435,  -0.0472859498,   0.0282396037, ... 
            0.0142856452,  -0.0327675728,   0.0099626486,   0.0226354218, ... 
           -0.0244408014,  -0.0054289910,   0.0287901880,  -0.0117173661, ... 
           -0.0243177365,   0.0245372299,   0.0194400686,  -0.0299042181, ... 
           -0.0249619216 ]';
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

