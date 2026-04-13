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
local_max.m qroots.oct"

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
r = [   1.0000000000,  -0.6519257936,   0.9364960857,  -0.4867810215, ... 
        0.1339926042,   0.0072588421,  -0.0119087425,   0.0021975958, ... 
        0.0031293164 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.7866201153,   0.4890401028,  -0.1137505920, ... 
       -0.0409049239,   0.0237971103,   0.0053764569,   0.0007490602 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0015815838,   0.0150174921,  -0.0143926739,  -0.0333019569, ... 
         0.0106139608,   0.0106112042,  -0.0362001053,   0.0246262611, ... 
         0.1043689939,  -0.0672946564,  -0.2724869959,  -0.0147231945, ... 
         0.4448151746,   0.4701485321,   0.1665075645,   0.0408000348, ... 
         0.1000200270,   0.0575288937,  -0.0289951047,  -0.0125187284, ... 
         0.0128572960,  -0.0042254391,  -0.0019430905,   0.0119182250, ... 
         0.0145815801 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0071037832,  -0.0251161021,  -0.0152572706,   0.0283461281, ... 
        -0.0157247977,  -0.0568024608,   0.0262068783,   0.0688497158, ... 
         0.0088084293,  -0.0456079705,  -0.1885353225,  -0.0978885306, ... 
         0.4163952596,   0.5764303954,   0.1244347657,  -0.0371114449, ... 
         0.1939489808,   0.0687948227,  -0.1287112009,  -0.0038926704, ... 
         0.0750069669,  -0.0319424059,  -0.0298873056,   0.0351743801, ... 
         0.0125734342 ]';
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

