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
r = [   1.0000000000,  -0.0190718265,   0.4853999188,   0.0187094539, ... 
       -0.1105120445,   0.0003155549,   0.0399007725,   0.0123588895, ... 
       -0.0251988401,  -0.0022633151,   0.0034273440 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036128167,   0.0012964247,   0.0051922525,  -0.0073197207, ... 
        -0.0006344918,   0.0081106039,  -0.0044451401,  -0.0083329594, ... 
         0.0095222089,   0.0129514848,  -0.0167761624,  -0.0117637340, ... 
         0.0348687029,  -0.0055652711,  -0.0430494050,   0.0337860169, ... 
         0.0504924367,  -0.0843254723,  -0.0628346843,   0.3064587758, ... 
         0.5702936577,   0.3064587758,  -0.0628346843,  -0.0843254723, ... 
         0.0504924367,   0.0337860169,  -0.0430494050,  -0.0055652711, ... 
         0.0348687029,  -0.0117637340,  -0.0167761624,   0.0129514848, ... 
         0.0095222089,  -0.0083329594,  -0.0044451401,   0.0081106039, ... 
        -0.0006344918,  -0.0073197207,   0.0051922525,   0.0012964247, ... 
        -0.0036128167 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0026401099,  -0.0024051683,  -0.0009194645,   0.0057343321, ... 
        -0.0062591002,   0.0010366831,   0.0078064039,  -0.0096893401, ... 
         0.0011477508,   0.0156944770,  -0.0178240005,  -0.0006919368, ... 
         0.0282060192,  -0.0333821916,   0.0024071095,   0.0491930024, ... 
        -0.0647115396,   0.0025834131,   0.1348761074,  -0.2732949395, ... 
        -0.6665318197,  -0.2732949395,   0.1348761074,   0.0025834131, ... 
        -0.0647115396,   0.0491930024,   0.0024071095,  -0.0333821916, ... 
         0.0282060192,  -0.0006919368,  -0.0178240005,   0.0156944770, ... 
         0.0011477508,  -0.0096893401,   0.0078064039,   0.0010366831, ... 
        -0.0062591002,   0.0057343321,  -0.0009194645,  -0.0024051683, ... 
         0.0026401099 ]';
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

