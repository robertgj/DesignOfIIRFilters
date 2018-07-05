#!/bin/sh

prog=frm2ndOrderCascade_socp_test.m

depends="frm2ndOrderCascade_socp_test.m test_common.m \
frm2ndOrderCascade_socp.m frm2ndOrderCascade.m tf2casc.m casc2tf.m \
frm2ndOrderCascade_vec_to_struct.m frm2ndOrderCascade_struct_to_vec.m \
frm_lowpass_vectors.m stability2ndOrderCascade.m print_polynomial.m \
qroots.m qzsolve.oct \
SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
a = [  -0.0667170278,   0.2072222224,  -0.2564183183,   0.0445051150, ... 
        0.2504769236,  -0.0228298931,  -0.8468638786,  -0.4400770814, ... 
       -0.6458888523,   1.1963504417,  -0.1175594719 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1393989143,   1.0803301803,  -1.0243365962, ... 
        0.3984039300,   0.0748337518,  -0.2414985607,   0.1864765167, ... 
       -0.0782877619,   0.0174743915,  -0.0016926915 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037188051,  -0.0091770693,  -0.0029972558,   0.0149046133, ... 
        -0.0084108586,  -0.0131322479,   0.0227058672,   0.0020477508, ... 
        -0.0214720599,   0.0346003314,  -0.0133630204,  -0.0454715734, ... 
         0.0734978108,  -0.0105544877,  -0.1387274047,   0.2788539216, ... 
         0.6784876502,   0.2788539216,  -0.1387274047,  -0.0105544877, ... 
         0.0734978108,  -0.0454715734,  -0.0133630204,   0.0346003314, ... 
        -0.0214720599,   0.0020477508,   0.0227058672,  -0.0131322479, ... 
        -0.0084108586,   0.0149046133,  -0.0029972558,  -0.0091770693, ... 
         0.0037188051 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017273491,  -0.0048752423,  -0.0004524794,   0.0074973804, ... 
        -0.0065893469,  -0.0051553329,   0.0136094779,  -0.0029601105, ... 
        -0.0089487654,   0.0278711176,  -0.0228467868,  -0.0300079240, ... 
         0.0718620116,  -0.0265049180,  -0.1223769844,   0.2864930837, ... 
         0.6527019507,   0.2864930837,  -0.1223769844,  -0.0265049180, ... 
         0.0718620116,  -0.0300079240,  -0.0228467868,   0.0278711176, ... 
        -0.0089487654,  -0.0029601105,   0.0136094779,  -0.0051553329, ... 
        -0.0065893469,   0.0074973804,  -0.0004524794,  -0.0048752423, ... 
         0.0017273491 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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

