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
a = [  -0.0666293277,   0.2071469885,  -0.2565861618,   0.0449119839, ... 
        0.2503305784,  -0.0230588880,  -0.8472453426,  -0.4398633912, ... 
       -0.6432102175,   1.1973143380,  -0.1170985358 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1418485059,   1.0827360846,  -1.0270436710, ... 
        0.3995895082,   0.0754071326,  -0.2431511354,   0.1880677624, ... 
       -0.0791867093,   0.0177189064,  -0.0017168154 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037047023,  -0.0092260589,  -0.0029953762,   0.0149450593, ... 
        -0.0084253670,  -0.0131577563,   0.0227182627,   0.0020493980, ... 
        -0.0215143096,   0.0345852742,  -0.0133872379,  -0.0454739530, ... 
         0.0735235595,  -0.0105609048,  -0.1387619237,   0.2788286486, ... 
         0.6785086838,   0.2788286486,  -0.1387619237,  -0.0105609048, ... 
         0.0735235595,  -0.0454739530,  -0.0133872379,   0.0345852742, ... 
        -0.0215143096,   0.0020493980,   0.0227182627,  -0.0131577563, ... 
        -0.0084253670,   0.0149450593,  -0.0029953762,  -0.0092260589, ... 
         0.0037047023 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017156192,  -0.0049132663,  -0.0004494146,   0.0075301391, ... 
        -0.0066043664,  -0.0051760735,   0.0136281033,  -0.0029584889, ... 
        -0.0089880886,   0.0278701464,  -0.0228613453,  -0.0300260528, ... 
         0.0718870565,  -0.0264942538,  -0.1224187303,   0.2864670488, ... 
         0.6527382891,   0.2864670488,  -0.1224187303,  -0.0264942538, ... 
         0.0718870565,  -0.0300260528,  -0.0228613453,   0.0278701464, ... 
        -0.0089880886,  -0.0029584889,   0.0136281033,  -0.0051760735, ... 
        -0.0066043664,   0.0075301391,  -0.0004494146,  -0.0049132663, ... 
         0.0017156192 ]';
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

