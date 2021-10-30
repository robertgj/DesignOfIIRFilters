#!/bin/sh

prog=iir_frm_parallel_allpass_socp_slb_test.m

depends="iir_frm_parallel_allpass_socp_slb_test.m test_common.m \
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
r = [   1.0000000000,  -0.4956969772,   0.8765484709,  -0.3777662309, ... 
        0.1082896395,   0.0081312135,  -0.0155350149,   0.0016441908, ... 
        0.0019437820 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.6443279069,   0.3944171689,  -0.0541294311, ... 
       -0.0544349722,   0.0206658408,   0.0052722305,   0.0006829741 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0024664881,  -0.0060536346,  -0.0220855959,  -0.0067119414, ... 
         0.0105571565,  -0.0352994090,  -0.0295749260,   0.0946562191, ... 
         0.0935681338,  -0.1516720355,  -0.1927818146,   0.2215896276, ... 
         0.5360094592,   0.3517173890,   0.0677212920,   0.0318410890, ... 
         0.0550803334,  -0.0295124895,  -0.0503134546,   0.0121262590, ... 
         0.0165689951,  -0.0107224740,   0.0019136667,   0.0209987915, ... 
         0.0217305543 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0209427013,  -0.0423337030,   0.0171702685,   0.0364429307, ... 
        -0.0543859427,  -0.0562051942,   0.0534111906,   0.0731878780, ... 
         0.0150587888,  -0.0751390177,  -0.1675803101,   0.1231824898, ... 
         0.5789267188,   0.4259565849,  -0.0235728558,   0.0204423441, ... 
         0.1568723065,  -0.0899295674,  -0.1426155787,   0.0699757777, ... 
         0.0636064270,  -0.0579289880,  -0.0071692059,   0.0514024658, ... 
         0.0080791831 ]';
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

