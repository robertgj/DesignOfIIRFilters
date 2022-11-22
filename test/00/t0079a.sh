#!/bin/sh

prog=iir_frm_parallel_allpass_socp_slb_test.m

depends="test/iir_frm_parallel_allpass_socp_slb_test.m test_common.m \
../tarczynski_frm_parallel_allpass_test_r_coef.m \
../tarczynski_frm_parallel_allpass_test_s_coef.m \
../tarczynski_frm_parallel_allpass_test_aa_coef.m \
../tarczynski_frm_parallel_allpass_test_ac_coef.m \
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
r = [   1.0000000000,  -0.4664304555,   0.7022953353,  -0.3168180412, ... 
        0.0321675370,   0.0513561551,  -0.0164692728,  -0.0030053206, ... 
        0.0045139360 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.6508578076,   0.2601517515,   0.0240070696, ... 
       -0.0673152876,   0.0158265219,   0.0083994995,   0.0018483866 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0014770581,  -0.0053564834,  -0.0249854773,  -0.0102281424, ... 
         0.0230700988,  -0.0136378662,  -0.0372356429,   0.0580137604, ... 
         0.0804388609,  -0.1312159512,  -0.1887875967,   0.2044797152, ... 
         0.5455114831,   0.3740437521,   0.0517766492,   0.0019662712, ... 
         0.0623613437,   0.0003441574,  -0.0391646449,   0.0078979561, ... 
         0.0154173153,  -0.0129899465,  -0.0031348516,   0.0193170939, ... 
         0.0220422430 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0146917087,  -0.0455026990,   0.0035996595,   0.0380651322, ... 
        -0.0335485483,  -0.0482202987,   0.0468098038,   0.0568932874, ... 
        -0.0079215122,  -0.0703838767,  -0.1472877866,   0.1104240654, ... 
         0.5698329577,   0.4582335488,  -0.0293843553,  -0.0273154405, ... 
         0.1670391334,  -0.0407749549,  -0.1395930419,   0.0533386443, ... 
         0.0687546425,  -0.0593887376,  -0.0193526275,   0.0516059303, ... 
         0.0152035341 ]';
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

