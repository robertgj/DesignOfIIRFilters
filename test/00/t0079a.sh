#!/bin/sh

prog=iir_frm_parallel_allpass_socp_slb_test.m

depends="iir_frm_parallel_allpass_socp_slb_test.m test_common.m \
iir_frm_parallel_allpass.m \
iir_frm_parallel_allpass_slb.m \
iir_frm_parallel_allpass_slb_constraints_are_empty.m \
iir_frm_parallel_allpass_slb_exchange_constraints.m \
iir_frm_parallel_allpass_slb_set_empty_constraints.m \
iir_frm_parallel_allpass_slb_show_constraints.m \
iir_frm_parallel_allpass_slb_update_constraints.m \
iir_frm_parallel_allpass_socp_mmse.m \
iir_frm_parallel_allpass_socp_slb_plot.m \
iir_frm_parallel_allpass_struct_to_vec.m \
iir_frm_parallel_allpass_vec_to_struct.m \
allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m \
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
cat > test_r_coef.m.ok << 'EOF'
r = [   1.0000000000,  -0.4207621416,   0.8262054052,  -0.3502609150, ... 
        0.1027139874,   0.0102580564,  -0.0167073755,   0.0023845660, ... 
        0.0024771933 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.5871569439,   0.3396514824,  -0.0358786129, ... 
       -0.0513218023,   0.0205522728,   0.0036647205,   0.0003516918 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0077699001,  -0.0167263716,  -0.0213854351,   0.0107424955, ... 
         0.0109339428,  -0.0592888052,  -0.0301327261,   0.1226425943, ... 
         0.0997208639,  -0.1547959459,  -0.1487360710,   0.2795235551, ... 
         0.5339671903,   0.3177682259,   0.0539172777,   0.0176570013, ... 
         0.0126020945,  -0.0589969747,  -0.0431487916,   0.0242332212, ... 
         0.0182748548,  -0.0103067948,   0.0032725487,   0.0229137148, ... 
         0.0219123032 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0378885798,  -0.0451279770,   0.0388525722,   0.0407256138, ... 
        -0.0672586962,  -0.0558077527,   0.0498688000,   0.0718606088, ... 
         0.0423995824,  -0.0681289075,  -0.1546674925,   0.1936884552, ... 
         0.6044295209,   0.3609383760,  -0.0450901674,   0.0419458869, ... 
         0.1007489524,  -0.1482696030,  -0.1189680853,   0.1009854329, ... 
         0.0560526770,  -0.0567808570,   0.0033055205,   0.0477725386, ... 
         0.0040983319 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
diff -Bb test_r_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_r_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on r.coef"; fail; fi
diff -Bb test_s_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_s_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on s.coef"; fail; fi
diff -Bb test_aa_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi
diff -Bb test_ac_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

