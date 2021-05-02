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
a = [   0.0023533354,  -0.0005342448,  -0.0030459005,  -0.0003339592, ... 
        0.0078294352,   0.0002252973,  -0.0157987965,   0.0336042377, ... 
       -0.0288672789,   0.0095499613,   0.0053809132 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.3179857660,   0.6690908933,   0.2333523116, ... 
        0.0340248649,  -0.0080987238,  -0.0038221582,  -0.0007019411, ... 
       -0.0000907095,  -0.0000090928,  -0.0000005214 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.1765772813,   0.1309564963,  -0.4528414768,   0.2990561313, ... 
         0.1455528650,  -0.2089264830,   0.1240039225,   0.2157638042, ... 
        -0.2762548629,  -0.0541912858,   0.4472054326,  -0.3322186208, ... 
        -0.2147786993,   0.4247653430,   0.0436368623,  -0.5013510112, ... 
         0.3261583368,   0.3609287210,  -0.2729858141,   0.5220845527, ... 
         0.3149827154,   0.5220845527,  -0.2729858141,   0.3609287210, ... 
         0.3261583368,  -0.5013510112,   0.0436368623,   0.4247653430, ... 
        -0.2147786993,  -0.3322186208,   0.4472054326,  -0.0541912858, ... 
        -0.2762548629,   0.2157638042,   0.1240039225,  -0.2089264830, ... 
         0.1455528650,   0.2990561313,  -0.4528414768,   0.1309564963, ... 
         0.1765772813 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0049014433,  -0.0059959929,   0.0144903551,  -0.0064793640, ... 
        -0.0080155525,   0.0049399733,   0.0024101857,  -0.0097911177, ... 
         0.0020713954,   0.0241168493,  -0.0031991104,  -0.0358592452, ... 
         0.0357906323,   0.0148083512,  -0.0447354357,   0.0196485649, ... 
         0.0607139991,  -0.0754249438,  -0.0853395168,   0.2955655069, ... 
         0.6051581244,   0.2955655069,  -0.0853395168,  -0.0754249438, ... 
         0.0607139991,   0.0196485649,  -0.0447354357,   0.0148083512, ... 
         0.0357906323,  -0.0358592452,  -0.0031991104,   0.0241168493, ... 
         0.0020713954,  -0.0097911177,   0.0024101857,   0.0049399733, ... 
        -0.0080155525,  -0.0064793640,   0.0144903551,  -0.0059959929, ... 
        -0.0049014433 ]';
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

