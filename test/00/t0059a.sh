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
a = [  -0.0665914944,   0.2071037076,  -0.2566185237,   0.0450229040, ... 
        0.2503093275,  -0.0231367806,  -0.8474374358,  -0.4397692253, ... 
       -0.6421496851,   1.1977676102,  -0.1168367287 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1428028424,   1.0836182875,  -1.0280700399, ... 
        0.3999794311,   0.0756914004,  -0.2438380011,   0.1887102137, ... 
       -0.0795447863,   0.0178143844,  -0.0017256737 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037017815,  -0.0092440135,  -0.0029964622,   0.0149600057, ... 
        -0.0084290059,  -0.0131654385,   0.0227237148,   0.0020507212, ... 
        -0.0215312317,   0.0345849350,  -0.0133922087,  -0.0454783411, ... 
         0.0735298733,  -0.0105590221,  -0.1387690008,   0.2788191406, ... 
         0.6785171230,   0.2788191406,  -0.1387690008,  -0.0105590221, ... 
         0.0735298733,  -0.0454783411,  -0.0133922087,   0.0345849350, ... 
        -0.0215312317,   0.0020507212,   0.0227237148,  -0.0131654385, ... 
        -0.0084290059,   0.0149600057,  -0.0029964622,  -0.0092440135, ... 
         0.0037017815 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017125152,  -0.0049274618,  -0.0004492019,   0.0075423635, ... 
        -0.0066091028,  -0.0051824318,   0.0136360938,  -0.0029575747, ... 
        -0.0090038858,   0.0278744730,  -0.0228637163,  -0.0300362556, ... 
         0.0718944072,  -0.0264864663,  -0.1224309013,   0.2864569859, ... 
         0.6527531622,   0.2864569859,  -0.1224309013,  -0.0264864663, ... 
         0.0718944072,  -0.0300362556,  -0.0228637163,   0.0278744730, ... 
        -0.0090038858,  -0.0029575747,   0.0136360938,  -0.0051824318, ... 
        -0.0066091028,   0.0075423635,  -0.0004492019,  -0.0049274618, ... 
         0.0017125152 ]';
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

