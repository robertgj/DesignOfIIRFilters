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
r = [   1.0000000000,  -0.2822930552,   0.7132749698,  -0.7090891710, ... 
        0.0252249113,  -0.1586838199,   0.0774977329,   0.0290077805, ... 
        0.0121407789 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.4716198375,   0.5215166694,  -0.6567479427, ... 
        0.0910687346,  -0.0620123141,   0.0762915446,   0.0044666574 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0053239823,   0.0153185071,  -0.0041247357,  -0.0435161345, ... 
        -0.0137269654,   0.0303067097,  -0.0168218204,  -0.0372896038, ... 
         0.0142932471,  -0.0631501741,  -0.1509659990,   0.1228017508, ... 
         0.5305447264,   0.4546314768,   0.0353717639,  -0.0784196395, ... 
         0.0841803986,   0.0877858105,  -0.0308453913,  -0.0263308683, ... 
         0.0381207130,   0.0295764965,   0.0085037172,   0.0083873051, ... 
        -0.0005359112 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0063073373,   0.0466378122,   0.0050545149,  -0.1127948045, ... 
         0.0020969706,   0.1273544054,  -0.0808992794,  -0.1294125200, ... 
         0.1346682976,  -0.0513846381,  -0.2731229201,   0.1940491427, ... 
         0.5933220890,   0.3347840107,   0.0663074122,   0.0285090293, ... 
        -0.0287577657,   0.0542460912,   0.0889287392,  -0.0454028314, ... 
        -0.0543033872,   0.0715133186,   0.0525633643,  -0.0263053964, ... 
        -0.0098675833 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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

