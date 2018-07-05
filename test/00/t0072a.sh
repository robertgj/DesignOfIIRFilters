#!/bin/sh

prog=iir_frm_socp_slb_test.m

depends="iir_frm_socp_slb_test.m test_common.m \
iir_frm.m \
iir_frm_slb.m \
iir_frm_slb_constraints_are_empty.m \
iir_frm_slb_exchange_constraints.m \
iir_frm_slb_set_empty_constraints.m \
iir_frm_slb_show_constraints.m \
iir_frm_slb_update_constraints.m \
iir_frm_socp_mmse.m \
iir_frm_socp_slb_plot.m \
iir_frm_struct_to_vec.m \
iir_frm_vec_to_struct.m \
iirA.m iirP.m iirT.m iirdelAdelw.m fixResultNaN.m tf2x.m x2tf.m \
xConstraints.m print_polynomial.m print_pole_zero.m \
local_max.m local_peak.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
a = [   0.0118701452,   0.0405412999,  -0.0397658712,  -0.0750606867, ... 
        0.1005146514,   0.1695238426,  -0.1986376058,   0.4294613271, ... 
       -0.5331581689,   0.2726863190,   0.1260356390 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.1233400046,   0.5332473554,   0.1203534903, ... 
       -0.0523986998,  -0.0275602795,  -0.0019177559,   0.0177435524, ... 
        0.0151398835,   0.0052621194,  -0.0004034527 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0025399907,   0.0031690583,  -0.0013457396,  -0.0005652413, ... 
         0.0010460510,   0.0003765795,  -0.0052200641,   0.0055708566, ... 
        -0.0017334210,  -0.0188082604,   0.0255837099,  -0.0082825113, ... 
        -0.0177452984,   0.0267804424,  -0.0021323578,  -0.0512301837, ... 
         0.0639056583,  -0.0023753362,  -0.1414590685,   0.2836201329, ... 
         0.6573629509,   0.2836201329,  -0.1414590685,  -0.0023753362, ... 
         0.0639056583,  -0.0512301837,  -0.0021323578,   0.0267804424, ... 
        -0.0177452984,  -0.0082825113,   0.0255837099,  -0.0188082604, ... 
        -0.0017334210,   0.0055708566,  -0.0052200641,   0.0003765795, ... 
         0.0010460510,  -0.0005652413,  -0.0013457396,   0.0031690583, ... 
        -0.0025399907 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0155894131,  -0.0183092904,   0.0017218365,   0.0156685055, ... 
        -0.0111631475,  -0.0134379699,   0.0368191642,  -0.0132894128, ... 
        -0.0309421581,   0.0169349285,   0.0299117227,  -0.0507196645, ... 
         0.0110041712,   0.0474343733,  -0.0467282949,  -0.0441337596, ... 
         0.1046140812,  -0.0401352317,  -0.1129214418,   0.2860287381, ... 
         0.6375840459,   0.2860287381,  -0.1129214418,  -0.0401352317, ... 
         0.1046140812,  -0.0441337596,  -0.0467282949,   0.0474343733, ... 
         0.0110041712,  -0.0507196645,   0.0299117227,   0.0169349285, ... 
        -0.0309421581,  -0.0132894128,   0.0368191642,  -0.0134379699, ... 
        -0.0111631475,   0.0156685055,   0.0017218365,  -0.0183092904, ... 
         0.0155894131 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_a_coef.m.ok iir_frm_socp_slb_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on a.coef"; fail; fi

diff -Bb test_d_coef.m.ok iir_frm_socp_slb_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on d.coef"; fail; fi

diff -Bb test_aa_coef.m.ok iir_frm_socp_slb_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi

diff -Bb test_ac_coef.m.ok iir_frm_socp_slb_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

