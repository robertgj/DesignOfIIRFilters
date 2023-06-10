#!/bin/sh

prog=iir_frm_parallel_allpass_socp_slb_test.m

depends="test/iir_frm_parallel_allpass_socp_slb_test.m test_common.m delayz.m \
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
r = [   1.0000000000,  -0.4789292094,   0.7133959943,  -0.3331502818, ... 
        0.0486974865,   0.0489595164,  -0.0181775201,  -0.0029581823, ... 
        0.0050655685 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.6634151167,   0.2705169341,   0.0214942878, ... 
       -0.0643160251,   0.0160254478,   0.0075138995,   0.0015661902 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0033081614,  -0.0076254625,  -0.0221045656,  -0.0027477944, ... 
         0.0240489687,  -0.0242908733,  -0.0466630146,   0.0636342753, ... 
         0.0959178593,  -0.1189950023,  -0.1868789009,   0.1984905609, ... 
         0.5416360430,   0.3801775548,   0.0603957369,  -0.0018029484, ... 
         0.0456642320,  -0.0132802351,  -0.0395326160,   0.0145026696, ... 
         0.0204129708,  -0.0132322155,  -0.0058610685,   0.0178827827, ... 
         0.0222062470 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0184879765,  -0.0470724068,   0.0106915006,   0.0462131283, ... 
        -0.0355029980,  -0.0582434471,   0.0377568032,   0.0594476351, ... 
         0.0091837562,  -0.0576066453,  -0.1473245910,   0.1046713944, ... 
         0.5688366440,   0.4614500900,  -0.0211916804,  -0.0282162312, ... 
         0.1503099440,  -0.0582223400,  -0.1411625578,   0.0633333804, ... 
         0.0768208545,  -0.0590353950,  -0.0231963753,   0.0488868328, ... 
         0.0144948323 ]';
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

