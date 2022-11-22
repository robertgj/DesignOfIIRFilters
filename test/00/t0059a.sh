#!/bin/sh

prog=frm2ndOrderCascade_socp_test.m

depends="test/frm2ndOrderCascade_socp_test.m test_common.m \
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
a = [  -0.0667264485,   0.2072379724,  -0.2564288787,   0.0445084083, ... 
        0.2504619393,  -0.0228221368,  -0.8467977459,  -0.4400852109, ... 
       -0.6461068568,   1.1962269573,  -0.1176617192 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1392092158,   1.0801770789,  -1.0241484897, ... 
        0.3983763818,   0.0747241150,  -0.2413146528,   0.1863163732, ... 
       -0.0782003558,   0.0174506101,  -0.0016902169 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037168368,  -0.0091745988,  -0.0029947953,   0.0149019252, ... 
        -0.0084125073,  -0.0131311784,   0.0227050116,   0.0020457162, ... 
        -0.0214679889,   0.0345970647,  -0.0133656744,  -0.0454675155, ... 
         0.0734989422,  -0.0105590899,  -0.1387286863,   0.2788564015, ... 
         0.6784834603,   0.2788564015,  -0.1387286863,  -0.0105590899, ... 
         0.0734989422,  -0.0454675155,  -0.0133656744,   0.0345970647, ... 
        -0.0214679889,   0.0020457162,   0.0227050116,  -0.0131311784, ... 
        -0.0084125073,   0.0149019252,  -0.0029947953,  -0.0091745988, ... 
         0.0037168368 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017264062,  -0.0048730648,  -0.0004511635,   0.0074951130, ... 
        -0.0065898215,  -0.0051544916,   0.0136077603,  -0.0029613565, ... 
        -0.0089449370,   0.0278671481,  -0.0228490112,  -0.0300028725, ... 
         0.0718619282,  -0.0265100829,  -0.1223758020,   0.2864957398, ... 
         0.6526963763,   0.2864957398,  -0.1223758020,  -0.0265100829, ... 
         0.0718619282,  -0.0300028725,  -0.0228490112,   0.0278671481, ... 
        -0.0089449370,  -0.0029613565,   0.0136077603,  -0.0051544916, ... 
        -0.0065898215,   0.0074951130,  -0.0004511635,  -0.0048730648, ... 
         0.0017264062 ]';
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

