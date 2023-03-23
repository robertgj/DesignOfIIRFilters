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
r = [   1.0000000000,  -0.0179178576,   0.4858472887,   0.0197961974, ... 
       -0.1094882771,   0.0021559105,   0.0409312121,   0.0136026750, ... 
       -0.0243583440,  -0.0013972184,   0.0037666696 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0019030121,  -0.0021322113,   0.0096233337,  -0.0111941847, ... 
         0.0019452540,   0.0068642271,  -0.0034969417,  -0.0092280371, ... 
         0.0103532115,   0.0089865771,  -0.0097705961,  -0.0205183870, ... 
         0.0421279321,  -0.0101262826,  -0.0412048465,   0.0321188827, ... 
         0.0521953248,  -0.0860692981,  -0.0574518004,   0.2975143106, ... 
         0.5814986866,   0.2975143106,  -0.0574518004,  -0.0860692981, ... 
         0.0521953248,   0.0321188827,  -0.0412048465,  -0.0101262826, ... 
         0.0421279321,  -0.0205183870,  -0.0097705961,   0.0089865771, ... 
         0.0103532115,  -0.0092280371,  -0.0034969417,   0.0068642271, ... 
         0.0019452540,  -0.0111941847,   0.0096233337,  -0.0021322113, ... 
        -0.0019030121 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0011515479,   0.0002082036,  -0.0042745770,   0.0086658428, ... 
        -0.0082598745,   0.0014878619,   0.0079424366,  -0.0103349551, ... 
         0.0020261219,   0.0119154207,  -0.0120804034,  -0.0077904812, ... 
         0.0342563469,  -0.0376315718,   0.0036245611,   0.0487027322, ... 
        -0.0650705384,   0.0034704577,   0.1303840970,  -0.2664801712, ... 
        -0.6751387290,  -0.2664801712,   0.1303840970,   0.0034704577, ... 
        -0.0650705384,   0.0487027322,   0.0036245611,  -0.0376315718, ... 
         0.0342563469,  -0.0077904812,  -0.0120804034,   0.0119154207, ... 
         0.0020261219,  -0.0103349551,   0.0079424366,   0.0014878619, ... 
        -0.0082598745,   0.0086658428,  -0.0042745770,   0.0002082036, ... 
         0.0011515479 ]';
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

