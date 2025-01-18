#!/bin/sh

prog=complementaryFIRlattice_socp_slb_bandpass_hilbert_test.m

depends="test/complementaryFIRlattice_socp_slb_bandpass_hilbert_test.m \
test_common.m \
../iir_sqp_slb_fir_17_bandpass_test_d1_coef.m \
complementaryFIRlatticeAsq.m \
complementaryFIRlatticeT.m \
complementaryFIRlatticeP.m \
complementaryFIRlatticeEsq.m \
complementaryFIRlattice_slb.m \
complementaryFIRlattice_slb_constraints_are_empty.m \
complementaryFIRlattice_socp_mmse.m \
complementaryFIRlattice_slb_exchange_constraints.m \
complementaryFIRlattice_slb_set_empty_constraints.m \
complementaryFIRlattice_slb_show_constraints.m \
complementaryFIRlattice_slb_update_constraints.m \
complementaryFIRlattice.m \
complementaryFIRlattice2Abcd.m \
complementaryFIRlatticeFilter.m \
local_max.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
direct_form_scale.m qroots.m \
minphase.oct Abcd2H.oct complementaryFIRdecomp.oct qzsolve.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        #rm -rf $tmp
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
cat > test_k2_coef.m << 'EOF'
k2 = [   0.9843749685,   0.9843749649,   0.9843749647,   0.9843749750, ... 
         0.9843749682,   0.9843749658,   0.9843749636,   0.9843749637, ... 
         0.9843749750,   0.9618355107,   0.9759519784,   0.9843749653, ... 
         0.8623803314,   0.9368887621,   0.9843749649,   0.9841197304, ... 
         0.1428549720 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_khat2_coef.m << 'EOF'
khat2 = [  -0.0508224333,  -0.0042400382,   0.0377825695,   0.0872221519, ... 
            0.0845389486,   0.0382116583,   0.0280453030,   0.0149503980, ... 
           -0.1741750700,  -0.4748358802,  -0.4452572333,   0.1164690056, ... 
            0.6348822593,   0.5257079660,   0.0115424375,  -0.2220128175, ... 
            0.9842765070 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_khat2_coef.m"; fail; fi

cat > test_Nh2_coef.m << 'EOF'
Nh2 = [   0.0896655463,   0.0697931742,  -0.0700176658,  -0.2163349597, ... 
         -0.2005861222,  -0.0102658956,   0.1934007495,   0.2007763271, ... 
          0.0569563045,  -0.0863731905,  -0.0884070161,  -0.0275717352, ... 
         -0.0041019027,  -0.0069099407,  -0.0087926541,  -0.0231274737, ... 
          0.0318964427 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Nh2_coef.m"; fail; fi

cat > test_Ng2_coef.m << 'EOF'
Ng2 = [   0.6177992232,  -0.4996333181,   0.3319981680,   0.5307796891, ... 
          0.3053385312,   0.0489459557,  -0.0511055378,  -0.0471352796, ... 
         -0.0406865261,  -0.0476517517,  -0.0375376060,  -0.0034500103, ... 
          0.0226209508,   0.0221365153,   0.0067642486,  -0.0039906111, ... 
         -0.0046293551 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Ng2_coef.m"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="complementaryFIRlattice_socp_slb_bandpass_hilbert_test"

for coef in k2 khat2 Nh2 Ng2 ; do
    diff -bBw test_$coef"_coef.m" $nstr"_"$coef"_coef.m"
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass
