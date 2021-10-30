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
local_max.m qroots.m qzsolve.oct"

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
a = [   0.0022574175,  -0.0003856072,  -0.0027595095,  -0.0002913358, ... 
        0.0073835373,   0.0002284888,  -0.0153221275,   0.0330348460, ... 
       -0.0281051890,   0.0094682254,   0.0051056788 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.3521272425,   0.7141523291,   0.2677170660, ... 
        0.0513747436,  -0.0062920449,  -0.0042631452,  -0.0008215398, ... 
       -0.0001055240,  -0.0000108168,  -0.0000006752 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.1701593060,   0.1319312285,  -0.4497416597,   0.2932353515, ... 
         0.1464374160,  -0.2109977991,   0.1201139514,   0.2206477912, ... 
        -0.2729177736,  -0.0527881523,   0.4404892084,  -0.3208778594, ... 
        -0.2248284178,   0.4249766182,   0.0531050787,  -0.5075630439, ... 
         0.3230415161,   0.3719536742,  -0.2890876162,   0.5123417610, ... 
         0.3302250109,   0.5123417610,  -0.2890876162,   0.3719536742, ... 
         0.3230415161,  -0.5075630439,   0.0531050787,   0.4249766182, ... 
        -0.2248284178,  -0.3208778594,   0.4404892084,  -0.0527881523, ... 
        -0.2729177736,   0.2206477912,   0.1201139514,  -0.2109977991, ... 
         0.1464374160,   0.2932353515,  -0.4497416597,   0.1319312285, ... 
         0.1701593060 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0041690449,  -0.0065146051,   0.0145550699,  -0.0061081822, ... 
        -0.0083581442,   0.0052554529,   0.0025742603,  -0.0101039149, ... 
         0.0020369694,   0.0235591544,  -0.0030508819,  -0.0359139687, ... 
         0.0356741884,   0.0146432325,  -0.0449544791,   0.0196228293, ... 
         0.0608444151,  -0.0754071910,  -0.0847376704,   0.2954658997, ... 
         0.6052781723,   0.2954658997,  -0.0847376704,  -0.0754071910, ... 
         0.0608444151,   0.0196228293,  -0.0449544791,   0.0146432325, ... 
         0.0356741884,  -0.0359139687,  -0.0030508819,   0.0235591544, ... 
         0.0020369694,  -0.0101039149,   0.0025742603,   0.0052554529, ... 
        -0.0083581442,  -0.0061081822,   0.0145550699,  -0.0065146051, ... 
        -0.0041690449 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

