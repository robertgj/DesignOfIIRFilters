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
r = [   1.0000000000,  -0.3385805628,   0.7007249396,  -0.7033077854, ... 
        0.0317538086,  -0.1447488851,   0.0759086311,   0.0271718143, ... 
        0.0114288392 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.5134912765,   0.5125624006,  -0.6414468971, ... 
        0.0940959579,  -0.0551595797,   0.0729161527,   0.0041140265 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0050541980,   0.0154156029,  -0.0039740877,  -0.0443399410, ... 
        -0.0133591520,   0.0294307434,  -0.0187320818,  -0.0354044807, ... 
         0.0191137886,  -0.0641707200,  -0.1572011229,   0.1226473789, ... 
         0.5329193104,   0.4525753645,   0.0349229325,  -0.0733966988, ... 
         0.0857206849,   0.0824929109,  -0.0325430378,  -0.0225030611, ... 
         0.0384336259,   0.0273931581,   0.0095838104,   0.0103849428, ... 
        -0.0009987581 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0074836497,   0.0481744528,   0.0045488852,  -0.1140507885, ... 
         0.0048688499,   0.1235746128,  -0.0861659476,  -0.1224314937, ... 
         0.1426349164,  -0.0609076547,  -0.2774448908,   0.2011588397, ... 
         0.5909292141,   0.3294378798,   0.0706162001,   0.0328096538, ... 
        -0.0319868506,   0.0556780195,   0.0871241657,  -0.0471422658, ... 
        -0.0508219904,   0.0729217830,   0.0499861011,  -0.0277806334, ... 
        -0.0069665382 ]';
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

