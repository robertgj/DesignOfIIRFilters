#!/bin/sh

prog=frm2ndOrderCascade_socp_test.m

depends="frm2ndOrderCascade_socp_test.m test_common.m \
frm2ndOrderCascade_socp.m frm2ndOrderCascade.m tf2casc.m casc2tf.m \
frm2ndOrderCascade_vec_to_struct.m frm2ndOrderCascade_struct_to_vec.m \
frm_lowpass_vectors.m stability2ndOrderCascade.m print_polynomial.m \
qroots.m qzsolve.oct"

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
cat > test_a_coef.m.ok << 'EOF'
a = [  -0.0666608263,   0.2071661897,  -0.2564968336,   0.0447180016, ... 
        0.2504145959,  -0.0229597383,  -0.8471343005,  -0.4399563780, ... 
       -0.6442452466,   1.1969861365,  -0.1172138677 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1408937575,   1.0817657800,  -1.0259629139, ... 
        0.3990556127,   0.0752597882,  -0.2425741035,   0.1874928988, ... 
       -0.0788587155,   0.0176300755,  -0.0017083324 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037133656,  -0.0092057211,  -0.0029989223,   0.0149290602, ... 
        -0.0084167612,  -0.0131473986,   0.0227129384,   0.0020507608, ... 
        -0.0214990382,   0.0345952033,  -0.0133732665,  -0.0454769790, ... 
         0.0735105603,  -0.0105531357,  -0.1387451849,   0.2788374154, ... 
         0.6785032503,   0.2788374154,  -0.1387451849,  -0.0105531357, ... 
         0.0735105603,  -0.0454769790,  -0.0133732665,   0.0345952033, ... 
        -0.0214990382,   0.0020507608,   0.0227129384,  -0.0131473986, ... 
        -0.0084167612,   0.0149290602,  -0.0029989223,  -0.0092057211, ... 
         0.0037133656 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017221068,  -0.0048977382,  -0.0004522946,   0.0075172466, ... 
        -0.0065967666,  -0.0051675524,   0.0136208789,  -0.0029579418, ... 
        -0.0089738319,   0.0278743693,  -0.0228523260,  -0.0300227675, ... 
         0.0718756074,  -0.0264938903,  -0.1224009983,   0.2864760949, ... 
         0.6527271029,   0.2864760949,  -0.1224009983,  -0.0264938903, ... 
         0.0718756074,  -0.0300227675,  -0.0228523260,   0.0278743693, ... 
        -0.0089738319,  -0.0029579418,   0.0136208789,  -0.0051675524, ... 
        -0.0065967666,   0.0075172466,  -0.0004522946,  -0.0048977382, ... 
         0.0017221068 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a_coef.m.ok frm2ndOrderCascade_socp_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on a.coef"; fail; fi

diff -Bb test_d_coef.m.ok frm2ndOrderCascade_socp_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on d.coef"; fail; fi

diff -Bb test_aa_coef.m.ok frm2ndOrderCascade_socp_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi

diff -Bb test_ac_coef.m.ok frm2ndOrderCascade_socp_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

