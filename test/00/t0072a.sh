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
local_max.m local_peak.m SeDuMi_1_3/"

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
a = [   0.0076278129,   0.0415842834,  -0.0436800082,  -0.0714979522, ... 
        0.1085671506,   0.1497643029,  -0.2114258252,   0.4429788162, ... 
       -0.5367456391,   0.2661302741,   0.1162560522 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi
cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.1042601496,   0.5355166651,   0.1081586819, ... 
       -0.0598776864,  -0.0284049728,  -0.0034188664,   0.0200735744, ... 
        0.0164328945,   0.0056710998,   0.0015312570 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0034746550,   0.0030234856,  -0.0001398567,  -0.0021948577, ... 
         0.0017451188,   0.0003487298,  -0.0064408521,   0.0066375025, ... 
        -0.0013765107,  -0.0209767262,   0.0236087830,  -0.0038054662, ... 
        -0.0208125940,   0.0257229528,  -0.0014666336,  -0.0517010363, ... 
         0.0636831303,  -0.0015554928,  -0.1430831955,   0.2806659316, ... 
         0.6620956646,   0.2806659316,  -0.1430831955,  -0.0015554928, ... 
         0.0636831303,  -0.0517010363,  -0.0014666336,   0.0257229528, ... 
        -0.0208125940,  -0.0038054662,   0.0236087830,  -0.0209767262, ... 
        -0.0013765107,   0.0066375025,  -0.0064408521,   0.0003487298, ... 
         0.0017451188,  -0.0021948577,  -0.0001398567,   0.0030234856, ... 
        -0.0034746550 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0157711738,  -0.0157990184,  -0.0011270081,   0.0164261558, ... 
        -0.0097246399,  -0.0126618740,   0.0352388908,  -0.0133314023, ... 
        -0.0289985951,   0.0145909018,   0.0258882622,  -0.0443994626, ... 
         0.0090112500,   0.0439635077,  -0.0460850933,  -0.0422553962, ... 
         0.1033167590,  -0.0416916996,  -0.1093247926,   0.2895974014, ... 
         0.6298718280,   0.2895974014,  -0.1093247926,  -0.0416916996, ... 
         0.1033167590,  -0.0422553962,  -0.0460850933,   0.0439635077, ... 
         0.0090112500,  -0.0443994626,   0.0258882622,   0.0145909018, ... 
        -0.0289985951,  -0.0133314023,   0.0352388908,  -0.0126618740, ... 
        -0.0097246399,   0.0164261558,  -0.0011270081,  -0.0157990184, ... 
         0.0157711738 ]';
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

