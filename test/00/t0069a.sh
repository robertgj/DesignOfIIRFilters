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
cat > test_r_coef.m.ok << 'EOF'
r = [   1.0000000000,  -0.0320124508,   0.4901794275,   0.0137668281, ... 
       -0.1089417263,  -0.0101518666,   0.0413561348,   0.0025899723, ... 
       -0.0240145966,  -0.0090648189,   0.0029257759 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036141734,   0.0023688890,   0.0040609734,  -0.0072180422, ... 
         0.0004518304,   0.0075699128,  -0.0050096215,  -0.0077382141, ... 
         0.0100267433,   0.0115614296,  -0.0176764369,  -0.0099890363, ... 
         0.0344231986,  -0.0074591053,  -0.0423641202,   0.0350484362, ... 
         0.0494641442,  -0.0854609580,  -0.0604622139,   0.3074017488, ... 
         0.5678867148,   0.3074017488,  -0.0604622139,  -0.0854609580, ... 
         0.0494641442,   0.0350484362,  -0.0423641202,  -0.0074591053, ... 
         0.0344231986,  -0.0099890363,  -0.0176764369,   0.0115614296, ... 
         0.0100267433,  -0.0077382141,  -0.0050096215,   0.0075699128, ... 
         0.0004518304,  -0.0072180422,   0.0040609734,   0.0023688890, ... 
        -0.0036141734 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017671370,  -0.0008395377,  -0.0028707836,   0.0073575668, ... 
        -0.0071779990,   0.0011122675,   0.0079653990,  -0.0100175042, ... 
         0.0014215921,   0.0138353741,  -0.0146770989,  -0.0046476291, ... 
         0.0315441294,  -0.0354268690,   0.0027993851,   0.0490980555, ... 
        -0.0650593907,   0.0030335212,   0.1324825822,  -0.2693023389, ... 
        -0.6715639679,  -0.2693023389,   0.1324825822,   0.0030335212, ... 
        -0.0650593907,   0.0490980555,   0.0027993851,  -0.0354268690, ... 
         0.0315441294,  -0.0046476291,  -0.0146770989,   0.0138353741, ... 
         0.0014215921,  -0.0100175042,   0.0079653990,   0.0011122675, ... 
        -0.0071779990,   0.0073575668,  -0.0028707836,  -0.0008395377, ... 
         0.0017671370 ]';
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

