#!/bin/sh

prog=frm2ndOrderCascade_socp_test.m

depends="test/frm2ndOrderCascade_socp_test.m test_common.m delayz.m \
frm2ndOrderCascade_socp.m frm2ndOrderCascade.m tf2casc.m casc2tf.m \
frm2ndOrderCascade_vec_to_struct.m frm2ndOrderCascade_struct_to_vec.m \
frm_lowpass_vectors.m stability2ndOrderCascade.m print_polynomial.m \
qroots.oct"

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
a = [  -0.0666732579,   0.2071781936,  -0.2564781055,   0.0446687476, ... 
        0.2504295457,  -0.0229297230,  -0.8470754522,  -0.4399864784, ... 
       -0.6446148898,   1.1968445872,  -0.1172877528 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1405581688,   1.0814439047,  -1.0255977972, ... 
        0.3989056546,   0.0751696910,  -0.2423388005,   0.1872696113, ... 
       -0.0787332643,   0.0175960571,  -0.0017049887 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037148544,  -0.0091991620,  -0.0029988105,   0.0149235662, ... 
        -0.0084151585,  -0.0131440569,   0.0227112584,   0.0020503078, ... 
        -0.0214930713,   0.0345965602,  -0.0133706260,  -0.0454760724, ... 
         0.0735075184,  -0.0105530078,  -0.1387411230,   0.2788409911, ... 
         0.6785000824,   0.2788409911,  -0.1387411230,  -0.0105530078, ... 
         0.0735075184,  -0.0454760724,  -0.0133706260,   0.0345965602, ... 
        -0.0214930713,   0.0020503078,   0.0227112584,  -0.0131440569, ... 
        -0.0084151585,   0.0149235662,  -0.0029988105,  -0.0091991620, ... 
         0.0037148544 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017234482,  -0.0048926100,  -0.0004524946,   0.0075127846, ... 
        -0.0065949369,  -0.0051648355,   0.0136182914,  -0.0029582989, ... 
        -0.0089682925,   0.0278738775,  -0.0228508319,  -0.0300197533, ... 
         0.0718724761,  -0.0264959787,  -0.1223956608,   0.2864797815, ... 
         0.6527218135,   0.2864797815,  -0.1223956608,  -0.0264959787, ... 
         0.0718724761,  -0.0300197533,  -0.0228508319,   0.0278738775, ... 
        -0.0089682925,  -0.0029582989,   0.0136182914,  -0.0051648355, ... 
        -0.0065949369,   0.0075127846,  -0.0004524946,  -0.0048926100, ... 
         0.0017234482 ]';
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

