#!/bin/sh

prog=iir_frm_allpass_socp_slb_test.m

depends="iir_frm_allpass_socp_slb_test.m test_common.m \
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
r = [   1.0000000000,  -0.0320492115,   0.4901754775,   0.0137118767, ... 
       -0.1090082086,  -0.0101924672,   0.0413312501,   0.0025101774, ... 
       -0.0240537521,  -0.0090690279,   0.0028783414 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036583381,   0.0024912372,   0.0039045043,  -0.0071164400, ... 
         0.0004318656,   0.0075698027,  -0.0050442829,  -0.0076811803, ... 
         0.0099884798,   0.0116405402,  -0.0178788825,  -0.0097176704, ... 
         0.0342348242,  -0.0073966630,  -0.0424072845,   0.0351444952, ... 
         0.0493728698,  -0.0854306535,  -0.0605369287,   0.3076570969, ... 
         0.5675197606,   0.3076570969,  -0.0605369287,  -0.0854306535, ... 
         0.0493728698,   0.0351444952,  -0.0424072845,  -0.0073966630, ... 
         0.0342348242,  -0.0097176704,  -0.0178788825,   0.0116405402, ... 
         0.0099884798,  -0.0076811803,  -0.0050442829,   0.0075698027, ... 
         0.0004318656,  -0.0071164400,   0.0039045043,   0.0024912372, ... 
        -0.0036583381 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017691771,  -0.0008495684,  -0.0028639619,   0.0073637953, ... 
        -0.0071970715,   0.0011303535,   0.0079599469,  -0.0100315905, ... 
         0.0014480418,   0.0138106593,  -0.0146710319,  -0.0046507954, ... 
         0.0315612441,  -0.0354649425,   0.0028363804,   0.0490821749, ... 
        -0.0650785551,   0.0030767369,   0.1324390315,  -0.2692853725, ... 
        -0.6715705713,  -0.2692853725,   0.1324390315,   0.0030767369, ... 
        -0.0650785551,   0.0490821749,   0.0028363804,  -0.0354649425, ... 
         0.0315612441,  -0.0046507954,  -0.0146710319,   0.0138106593, ... 
         0.0014480418,  -0.0100315905,   0.0079599469,   0.0011303535, ... 
        -0.0071970715,   0.0073637953,  -0.0028639619,  -0.0008495684, ... 
         0.0017691771 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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

