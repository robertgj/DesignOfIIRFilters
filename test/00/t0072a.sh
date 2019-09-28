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
iirA.m iirP.m iirT.m iirdelAdelw.m fixResultNaN.m tf2x.m zp2x.m x2tf.m \
xConstraints.m print_polynomial.m print_pole_zero.m \
local_max.m local_peak.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
a = [   0.0013190730,   0.0010277579,  -0.0023251495,  -0.0032208776, ... 
        0.0043164414,   0.0057150344,  -0.0119059073,   0.0157345374, ... 
       -0.0011234943,  -0.0073623698,   0.0027300262 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   1.6212902116,   1.9553110714,   1.6907794559, ... 
        0.8711701732,   0.2604156340,   0.0020319002,  -0.0223452879, ... 
       -0.0013984705,   0.0003294719,   0.0000262932 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.1571922627,  -0.0822971502,  -0.1481394919,   0.2530518550, ... 
         0.0020919246,  -0.2809351369,   0.2937779741,   0.1713826420, ... 
        -0.4317735725,   0.1212980918,   0.4296089556,  -0.4226045628, ... 
        -0.1823352008,   0.5635281684,  -0.1373163187,  -0.5022659737, ... 
         0.5002195580,   0.2531631996,  -0.4389571452,   0.2447750387, ... 
         0.9639878312,   0.2447750387,  -0.4389571452,   0.2531631996, ... 
         0.5002195580,  -0.5022659737,  -0.1373163187,   0.5635281684, ... 
        -0.1823352008,  -0.4226045628,   0.4296089556,   0.1212980918, ... 
        -0.4317735725,   0.1713826420,   0.2937779741,  -0.2809351369, ... 
         0.0020919246,   0.2530518550,  -0.1481394919,  -0.0822971502, ... 
         0.1571922627 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0038169287,   0.0011101086,   0.0047396470,  -0.0056489958, ... 
        -0.0024579599,   0.0076784423,  -0.0044851639,  -0.0076544271, ... 
         0.0086764314,   0.0150588994,  -0.0173549082,  -0.0109747976, ... 
         0.0315597605,  -0.0011098933,  -0.0430888625,   0.0327217038, ... 
         0.0510339303,  -0.0832668433,  -0.0673907169,   0.3086731557, ... 
         0.5701933284,   0.3086731557,  -0.0673907169,  -0.0832668433, ... 
         0.0510339303,   0.0327217038,  -0.0430888625,  -0.0011098933, ... 
         0.0315597605,  -0.0109747976,  -0.0173549082,   0.0150588994, ... 
         0.0086764314,  -0.0076544271,  -0.0044851639,   0.0076784423, ... 
        -0.0024579599,  -0.0056489958,   0.0047396470,   0.0011101086, ... 
        -0.0038169287 ]';
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

