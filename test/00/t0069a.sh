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
r = [   1.0000000000,  -0.0320123648,   0.4902405356,   0.0138442932, ... 
       -0.1088171248,  -0.0103513494,   0.0413720409,   0.0023876303, ... 
       -0.0240131840,  -0.0092390895,   0.0029740328 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036388866,   0.0024418594,   0.0039028429,  -0.0070641664, ... 
         0.0003528545,   0.0075664745,  -0.0049304839,  -0.0077912805, ... 
         0.0099944397,   0.0117097280,  -0.0179174571,  -0.0096435078, ... 
         0.0341399373,  -0.0072696567,  -0.0423840874,   0.0349397752, ... 
         0.0495679384,  -0.0854444592,  -0.0606718148,   0.3077480637, ... 
         0.5674245918,   0.3077480637,  -0.0606718148,  -0.0854444592, ... 
         0.0495679384,   0.0349397752,  -0.0423840874,  -0.0072696567, ... 
         0.0341399373,  -0.0096435078,  -0.0179174571,   0.0117097280, ... 
         0.0099944397,  -0.0077912805,  -0.0049304839,   0.0075664745, ... 
         0.0003528545,  -0.0070641664,   0.0039028429,   0.0024418594, ... 
        -0.0036388866 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017775742,  -0.0008675711,  -0.0028352635,   0.0072999655, ... 
        -0.0071268712,   0.0010739767,   0.0079651211,  -0.0099968520, ... 
         0.0013757469,   0.0139026973,  -0.0147599325,  -0.0045589186, ... 
         0.0314331700,  -0.0353226747,   0.0027199670,   0.0491101747, ... 
        -0.0650375604,   0.0029482665,   0.1325911628,  -0.2694240256, ... 
        -0.6714531842,  -0.2694240256,   0.1325911628,   0.0029482665, ... 
        -0.0650375604,   0.0491101747,   0.0027199670,  -0.0353226747, ... 
         0.0314331700,  -0.0045589186,  -0.0147599325,   0.0139026973, ... 
         0.0013757469,  -0.0099968520,   0.0079651211,   0.0010739767, ... 
        -0.0071268712,   0.0072999655,  -0.0028352635,  -0.0008675711, ... 
         0.0017775742 ]';
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

