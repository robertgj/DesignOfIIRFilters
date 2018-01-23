#!/bin/sh

prog=iir_frm_allpass_socp_slb_test.m

depends="iir_frm_allpass_socp_slb_test.m test_common.m \
iir_frm_allpass.m \
iir_frm_allpass_slb.m \
iir_frm_allpass_slb_constraints_are_empty.m \
iir_frm_allpass_slb_exchange_constraints.m \
iir_frm_allpass_slb_set_empty_constraints.m \
iir_frm_allpass_slb_show_constraints.m \
iir_frm_allpass_slb_update_constraints.m \
iir_frm_allpass_socp_mmse.m \
iir_frm_allpass_socp_slb_plot.m \
iir_frm_allpass_struct_to_vec.m \
iir_frm_allpass_vec_to_struct.m \
allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m \
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
cat > test_r_coef.m.ok << 'EOF'
r = [   1.0000000000,  -0.0320590553,   0.4903054365,   0.0138034084, ... 
       -0.1089307638,  -0.0101913920,   0.0412530056,   0.0024491534, ... 
       -0.0241234993,  -0.0091388456,   0.0028791749 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036033362,   0.0023926406,   0.0039878742,  -0.0071721701, ... 
         0.0004490460,   0.0075461637,  -0.0049793052,  -0.0077327162, ... 
         0.0099886216,   0.0115694409,  -0.0176965859,  -0.0099131298, ... 
         0.0343976340,  -0.0074552626,  -0.0423815161,   0.0350458672, ... 
         0.0494685434,  -0.0854543929,  -0.0604500199,   0.3074416518, ... 
         0.5677661186,   0.3074416518,  -0.0604500199,  -0.0854543929, ... 
         0.0494685434,   0.0350458672,  -0.0423815161,  -0.0074552626, ... 
         0.0343976340,  -0.0099131298,  -0.0176965859,   0.0115694409, ... 
         0.0099886216,  -0.0077327162,  -0.0049793052,   0.0075461637, ... 
         0.0004490460,  -0.0071721701,   0.0039878742,   0.0023926406, ... 
        -0.0036033362 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017788085,  -0.0008725081,  -0.0028356131,   0.0073446083, ... 
        -0.0071881587,   0.0011331737,   0.0079524582,  -0.0100275676, ... 
         0.0014423097,   0.0138372500,  -0.0147224124,  -0.0045872568, ... 
         0.0315104968,  -0.0354388082,   0.0028332925,   0.0490774544, ... 
        -0.0650752653,   0.0030699275,   0.1324731576,  -0.2693511644, ... 
        -0.6714880942,  -0.2693511644,   0.1324731576,   0.0030699275, ... 
        -0.0650752653,   0.0490774544,   0.0028332925,  -0.0354388082, ... 
         0.0315104968,  -0.0045872568,  -0.0147224124,   0.0138372500, ... 
         0.0014423097,  -0.0100275676,   0.0079524582,   0.0011331737, ... 
        -0.0071881587,   0.0073446083,  -0.0028356131,  -0.0008725081, ... 
         0.0017788085 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_r_coef.m.ok iir_frm_allpass_socp_slb_test_r_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on r.coef"; fail; fi
diff -Bb test_aa_coef.m.ok iir_frm_allpass_socp_slb_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi
diff -Bb test_ac_coef.m.ok iir_frm_allpass_socp_slb_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

