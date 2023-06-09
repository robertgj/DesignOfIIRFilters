#!/bin/sh

prog=iir_frm_allpass_socp_slb_test.m

depends="test/iir_frm_allpass_socp_slb_test.m test_common.m \
../tarczynski_frm_allpass_test_r1_coef.m \
../tarczynski_frm_allpass_test_aa1_coef.m \
../tarczynski_frm_allpass_test_ac1_coef.m \
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
r = [   1.0000000000,  -0.0370756433,   0.4913918693,   0.0164261157, ... 
       -0.1026968244,  -0.0054910649,   0.0429327831,   0.0144934693, ... 
       -0.0192442155,  -0.0006637845,   0.0027694354 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0009226458,  -0.0031693694,   0.0101266721,  -0.0108964138, ... 
         0.0013603971,   0.0074104163,  -0.0034798522,  -0.0090769471, ... 
         0.0096483711,   0.0079157431,  -0.0079557068,  -0.0221451038, ... 
         0.0425455947,  -0.0097745859,  -0.0420257754,   0.0317036517, ... 
         0.0524409300,  -0.0849276757,  -0.0572188949,   0.2962867814, ... 
         0.5836061881,   0.2962867814,  -0.0572188949,  -0.0849276757, ... 
         0.0524409300,   0.0317036517,  -0.0420257754,  -0.0097745859, ... 
         0.0425455947,  -0.0221451038,  -0.0079557068,   0.0079157431, ... 
         0.0096483711,  -0.0090769471,  -0.0034798522,   0.0074104163, ... 
         0.0013603971,  -0.0108964138,   0.0101266721,  -0.0031693694, ... 
        -0.0009226458 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0011481133,   0.0003668308,  -0.0044883786,   0.0087168929, ... 
        -0.0080745365,   0.0013626580,   0.0079542019,  -0.0101715725, ... 
         0.0017512779,   0.0123036363,  -0.0120933482,  -0.0079383402, ... 
         0.0340947219,  -0.0369649293,   0.0030862766,   0.0490715254, ... 
        -0.0651332060,   0.0033316095,   0.1306576061,  -0.2661213108, ... 
        -0.6758347650,  -0.2661213108,   0.1306576061,   0.0033316095, ... 
        -0.0651332060,   0.0490715254,   0.0030862766,  -0.0369649293, ... 
         0.0340947219,  -0.0079383402,  -0.0120933482,   0.0123036363, ... 
         0.0017512779,  -0.0101715725,   0.0079542019,   0.0013626580, ... 
        -0.0080745365,   0.0087168929,  -0.0044883786,   0.0003668308, ... 
         0.0011481133 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

