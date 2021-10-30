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
r = [   1.0000000000,  -0.0181718171,   0.4864229408,   0.0196422547, ... 
       -0.1090435735,   0.0020131124,   0.0409681065,   0.0133314295, ... 
       -0.0245281016,  -0.0015707329,   0.0036801303 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0015668780,  -0.0022782172,   0.0094564261,  -0.0107563505, ... 
         0.0012610836,   0.0079735606,  -0.0047045314,  -0.0081004922, ... 
         0.0094747200,   0.0088032062,  -0.0095485131,  -0.0205278156, ... 
         0.0419529989,  -0.0096700307,  -0.0427064801,   0.0339368898, ... 
         0.0503743537,  -0.0845342677,  -0.0577025737,   0.2976498495, ... 
         0.5813827082,   0.2976498495,  -0.0577025737,  -0.0845342677, ... 
         0.0503743537,   0.0339368898,  -0.0427064801,  -0.0096700307, ... 
         0.0419529989,  -0.0205278156,  -0.0095485131,   0.0088032062, ... 
         0.0094747200,  -0.0081004922,  -0.0047045314,   0.0079735606, ... 
         0.0012610836,  -0.0107563505,   0.0094564261,  -0.0022782172, ... 
        -0.0015668780 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0011693868,   0.0002748775,  -0.0043375660,   0.0086728857, ... 
        -0.0081196548,   0.0013791311,   0.0080323269,  -0.0103639914, ... 
         0.0020067666,   0.0120595583,  -0.0120514466,  -0.0078556367, ... 
         0.0342342145,  -0.0373425751,   0.0034096513,   0.0489589369, ... 
        -0.0653103606,   0.0037177388,   0.1302787321,  -0.2660741128, ... 
        -0.6756280525,  -0.2660741128,   0.1302787321,   0.0037177388, ... 
        -0.0653103606,   0.0489589369,   0.0034096513,  -0.0373425751, ... 
         0.0342342145,  -0.0078556367,  -0.0120514466,   0.0120595583, ... 
         0.0020067666,  -0.0103639914,   0.0080323269,   0.0013791311, ... 
        -0.0081196548,   0.0086728857,  -0.0043375660,   0.0002748775, ... 
         0.0011693868 ]';
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

