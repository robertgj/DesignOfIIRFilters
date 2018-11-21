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
a = [   0.0212359933,   0.0231461635,  -0.0578946566,  -0.0279831589, ... 
        0.1214286626,   0.0873018628,  -0.2272999739,   0.5347161279, ... 
       -0.6120089413,   0.2724292210,   0.1167455885 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.0457560260,   0.5420549492,   0.1098289876, ... 
       -0.0737762031,  -0.0364644325,   0.0167150851,   0.0376905838, ... 
        0.0143304646,   0.0009064463,  -0.0011032540 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0008535810,   0.0011888378,  -0.0003919291,  -0.0013614169, ... 
         0.0022633850,  -0.0006109813,  -0.0045104874,   0.0071034732, ... 
        -0.0037638532,  -0.0109357605,   0.0182762981,  -0.0051387417, ... 
        -0.0221997714,   0.0341213396,  -0.0076464324,  -0.0470815916, ... 
         0.0678915102,  -0.0077987117,  -0.1325162497,   0.2792188531, ... 
         0.6576437938,   0.2792188531,  -0.1325162497,  -0.0077987117, ... 
         0.0678915102,  -0.0470815916,  -0.0076464324,   0.0341213396, ... 
        -0.0221997714,  -0.0051387417,   0.0182762981,  -0.0109357605, ... 
        -0.0037638532,   0.0071034732,  -0.0045104874,  -0.0006109813, ... 
         0.0022633850,  -0.0013614169,  -0.0003919291,   0.0011888378, ... 
        -0.0008535810 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0078751578,  -0.0081838923,  -0.0039906467,   0.0185286039, ... 
        -0.0148494740,  -0.0076611771,   0.0276399272,  -0.0119313774, ... 
        -0.0238979093,   0.0226804606,   0.0105913094,  -0.0322075112, ... 
         0.0024824685,   0.0469668949,  -0.0476835701,  -0.0303071658, ... 
         0.0949300878,  -0.0457367894,  -0.1142224621,   0.3037881691, ... 
         0.6124438788,   0.3037881691,  -0.1142224621,  -0.0457367894, ... 
         0.0949300878,  -0.0303071658,  -0.0476835701,   0.0469668949, ... 
         0.0024824685,  -0.0322075112,   0.0105913094,   0.0226804606, ... 
        -0.0238979093,  -0.0119313774,   0.0276399272,  -0.0076611771, ... 
        -0.0148494740,   0.0185286039,  -0.0039906467,  -0.0081838923, ... 
         0.0078751578 ]';
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

