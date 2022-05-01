#!/bin/sh

prog=iir_frm_allpass_socp_slb_test.m

depends="iir_frm_allpass_socp_slb_test.m test_common.m \
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
r = [   1.0000000000,  -0.0189470249,   0.4865123105,   0.0190978169, ... 
       -0.1093824106,   0.0009756279,   0.0402398870,   0.0125728273, ... 
       -0.0251169616,  -0.0020192504,   0.0034131821 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0016821494,  -0.0021239529,   0.0093768963,  -0.0108094884, ... 
         0.0013830322,   0.0078746430,  -0.0046354371,  -0.0082329000, ... 
         0.0096799602,   0.0088349492,  -0.0098165660,  -0.0201947172, ... 
         0.0418016558,  -0.0097556981,  -0.0425037024,   0.0338403070, ... 
         0.0504424783,  -0.0846729482,  -0.0577420324,   0.2978996281, ... 
         0.5809995029,   0.2978996281,  -0.0577420324,  -0.0846729482, ... 
         0.0504424783,   0.0338403070,  -0.0425037024,  -0.0097556981, ... 
         0.0418016558,  -0.0201947172,  -0.0098165660,   0.0088349492, ... 
         0.0096799602,  -0.0082329000,  -0.0046354371,   0.0078746430, ... 
         0.0013830322,  -0.0108094884,   0.0093768963,  -0.0021239529, ... 
        -0.0016821494 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0012366160,   0.0001341499,  -0.0041863689,   0.0085669101, ... 
        -0.0080847066,   0.0013665249,   0.0081087355,  -0.0104873788, ... 
         0.0021823269,   0.0120414340,  -0.0121849857,  -0.0076371977, ... 
         0.0341302026,  -0.0373887400,   0.0035521550,   0.0489376070, ... 
        -0.0653912709,   0.0039084335,   0.1302476977,  -0.2662619338, ... 
        -0.6753011720,  -0.2662619338,   0.1302476977,   0.0039084335, ... 
        -0.0653912709,   0.0489376070,   0.0035521550,  -0.0373887400, ... 
         0.0341302026,  -0.0076371977,  -0.0121849857,   0.0120414340, ... 
         0.0021823269,  -0.0104873788,   0.0081087355,   0.0013665249, ... 
        -0.0080847066,   0.0085669101,  -0.0041863689,   0.0001341499, ... 
         0.0012366160 ]';
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

