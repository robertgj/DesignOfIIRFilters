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
r = [   1.0000000000,  -0.3704286118,   0.9189009076,  -0.2583515895, ... 
        0.1024895845,   0.0083509771,  -0.0123029432,   0.0006137678, ... 
        0.0009437005 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.5114314690,   0.4290000774,  -0.0468187356, ... 
       -0.0472471761,   0.0115784066,   0.0071590775,   0.0012726451 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0053370274,   0.0059303917,  -0.0287771575,  -0.0313941443, ... 
         0.0023327645,  -0.0145625025,  -0.0077857111,   0.0754300196, ... 
         0.0343660314,  -0.1969750577,  -0.1770953028,   0.2725720337, ... 
         0.5427161735,   0.2987409262,   0.0362888914,   0.0594057573, ... 
         0.1006354016,  -0.0076200747,  -0.0518245559,   0.0090188800, ... 
         0.0215373269,   0.0005533879,   0.0136118117,   0.0204376694, ... 
         0.0162418403 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0020261939,  -0.0253595202,   0.0025687681,   0.0050830483, ... 
        -0.0608160831,  -0.0330995292,   0.0706810605,   0.0524068477, ... 
        -0.0442776501,  -0.1148020138,  -0.1542668859,   0.1704794434, ... 
         0.5886725978,   0.3739038258,  -0.0614008347,   0.0510491486, ... 
         0.2016233093,  -0.0713487557,  -0.1238113505,   0.0726540725, ... 
         0.0499879455,  -0.0508923891,   0.0103345988,   0.0465953241, ... 
        -0.0012677001 ]';
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

