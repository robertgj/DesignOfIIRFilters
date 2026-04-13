#!/bin/sh

prog=iir_frm_allpass_socp_slb_test.m

depends="test/iir_frm_allpass_socp_slb_test.m test_common.m delayz.m \
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
r = [   1.0000000000,  -0.0364101866,   0.4887386438,   0.0201469782, ... 
       -0.1045567899,  -0.0039452939,   0.0409731663,   0.0160791141, ... 
       -0.0208063009,  -0.0007387356,   0.0018062921 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0014989338,  -0.0021743885,   0.0092690653,  -0.0107186914, ... 
         0.0017269708,   0.0070377163,  -0.0034825482,  -0.0091611237, ... 
         0.0102183487,   0.0081609646,  -0.0092794040,  -0.0204530795, ... 
         0.0417789242,  -0.0101434794,  -0.0412938217,   0.0317041086, ... 
         0.0524794120,  -0.0857696973,  -0.0571039482,   0.2975566768, ... 
         0.5814465574,   0.2975566768,  -0.0571039482,  -0.0857696973, ... 
         0.0524794120,   0.0317041086,  -0.0412938217,  -0.0101434794, ... 
         0.0417789242,  -0.0204530795,  -0.0092794040,   0.0081609646, ... 
         0.0102183487,  -0.0091611237,  -0.0034825482,   0.0070377163, ... 
         0.0017269708,  -0.0107186914,   0.0092690653,  -0.0021743885, ... 
        -0.0014989338 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0012102980,   0.0001891882,  -0.0042847145,   0.0086454842, ... 
        -0.0081828226,   0.0015313438,   0.0078349241,  -0.0101560105, ... 
         0.0017671534,   0.0124440384,  -0.0125551364,  -0.0073487939, ... 
         0.0337624103,  -0.0370413495,   0.0033272965,   0.0489129654, ... 
        -0.0651951808,   0.0034852134,   0.1307216691,  -0.2666941361, ... 
        -0.6749892797,  -0.2666941361,   0.1307216691,   0.0034852134, ... 
        -0.0651951808,   0.0489129654,   0.0033272965,  -0.0370413495, ... 
         0.0337624103,  -0.0073487939,  -0.0125551364,   0.0124440384, ... 
         0.0017671534,  -0.0101560105,   0.0078349241,   0.0015313438, ... 
        -0.0081828226,   0.0086454842,  -0.0042847145,   0.0001891882, ... 
         0.0012102980 ]';
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

