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
r = [   1.0000000000,  -0.0174479902,   0.4861277751,   0.0201691400, ... 
       -0.1091921541,   0.0025148035,   0.0409923785,   0.0136299426, ... 
       -0.0243776288,  -0.0013218743,   0.0038112570 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0018630362,  -0.0021435258,   0.0094933733,  -0.0107338802, ... 
         0.0010848963,   0.0079122848,  -0.0044459126,  -0.0084283651, ... 
         0.0097036627,   0.0091904959,  -0.0094989037,  -0.0209456470, ... 
         0.0420794981,  -0.0093020315,  -0.0425565099,   0.0334990330, ... 
         0.0508370719,  -0.0847854441,  -0.0581313812,   0.2974299687, ... 
         0.5819692637,   0.2974299687,  -0.0581313812,  -0.0847854441, ... 
         0.0508370719,   0.0334990330,  -0.0425565099,  -0.0093020315, ... 
         0.0420794981,  -0.0209456470,  -0.0094989037,   0.0091904959, ... 
         0.0097036627,  -0.0084283651,  -0.0044459126,   0.0079122848, ... 
         0.0010848963,  -0.0107338802,   0.0094933733,  -0.0021435258, ... 
        -0.0018630362 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0012426409,   0.0001326616,  -0.0041462504,   0.0085485837, ... 
        -0.0081042555,   0.0014340937,   0.0079762702,  -0.0103108681, ... 
         0.0019426461,   0.0122631200,  -0.0124227428,  -0.0073498638, ... 
         0.0338506953,  -0.0371550012,   0.0033694736,   0.0489679677, ... 
        -0.0653034614,   0.0036806778,   0.1304951850,  -0.2665300582, ... 
        -0.6749837911,  -0.2665300582,   0.1304951850,   0.0036806778, ... 
        -0.0653034614,   0.0489679677,   0.0033694736,  -0.0371550012, ... 
         0.0338506953,  -0.0073498638,  -0.0124227428,   0.0122631200, ... 
         0.0019426461,  -0.0103108681,   0.0079762702,   0.0014340937, ... 
        -0.0081042555,   0.0085485837,  -0.0041462504,   0.0001326616, ... 
         0.0012426409 ]';
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

