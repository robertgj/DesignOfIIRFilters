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
r = [   1.0000000000,  -0.0180673290,   0.4864943768,   0.0196559379, ... 
       -0.1090052815,   0.0020569476,   0.0409553542,   0.0132965463, ... 
       -0.0245628709,  -0.0015689112,   0.0036863288 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0016075654,  -0.0022121851,   0.0093876509,  -0.0106578459, ... 
         0.0011925262,   0.0079287305,  -0.0045589816,  -0.0082592126, ... 
         0.0095571944,   0.0088806292,  -0.0097012074,  -0.0203772455, ... 
         0.0417505519,  -0.0095235452,  -0.0426380226,   0.0336933137, ... 
         0.0506245258,  -0.0846204280,  -0.0578505269,   0.2978812363, ... 
         0.5811769023,   0.2978812363,  -0.0578505269,  -0.0846204280, ... 
         0.0506245258,   0.0336933137,  -0.0426380226,  -0.0095235452, ... 
         0.0417505519,  -0.0203772455,  -0.0097012074,   0.0088806292, ... 
         0.0095571944,  -0.0082592126,  -0.0045589816,   0.0079287305, ... 
         0.0011925262,  -0.0106578459,   0.0093876509,  -0.0022121851, ... 
        -0.0016075654 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0011831270,   0.0002254040,  -0.0042810647,   0.0086357765, ... 
        -0.0081158554,   0.0013974229,   0.0080093549,  -0.0103611450, ... 
         0.0020317939,   0.0120349719,  -0.0120813507,  -0.0077928395, ... 
         0.0341721457,  -0.0373176602,   0.0034133316,   0.0489309818, ... 
        -0.0652777787,   0.0036987039,   0.1302906016,  -0.2661239149, ... 
        -0.6755666847,  -0.2661239149,   0.1302906016,   0.0036987039, ... 
        -0.0652777787,   0.0489309818,   0.0034133316,  -0.0373176602, ... 
         0.0341721457,  -0.0077928395,  -0.0120813507,   0.0120349719, ... 
         0.0020317939,  -0.0103611450,   0.0080093549,   0.0013974229, ... 
        -0.0081158554,   0.0086357765,  -0.0042810647,   0.0002254040, ... 
         0.0011831270 ]';
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

