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
minphase.m local_max.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
direct_form_scale.m Abcd2H.oct complementaryFIRdecomp.oct qroots.m qzsolve.oct"

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
         0.9843749750,   0.9618355104,   0.9759519781,   0.9843749653, ... 
         0.8623803347,   0.9368887633,   0.9843749649,   0.9841197307, ... 
         0.1428549718 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_khat2_coef.m << 'EOF'
khat2 = [  -0.0508224320,  -0.0042400391,   0.0377825677,   0.0872221501, ... 
            0.0845389479,   0.0382116593,   0.0280453060,   0.0149504029, ... 
           -0.1741750676,  -0.4748358808,  -0.4452572356,   0.1164690027, ... 
            0.6348822549,   0.5257079641,   0.0115424401,  -0.2220128152, ... 
            0.9842765073 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_khat2_coef.m"; fail; fi

cat > test_Nh2_coef.m << 'EOF'
Nh2 = [   0.0896655466,   0.0697931738,  -0.0700176660,  -0.2163349593, ... 
         -0.2005861221,  -0.0102658962,   0.1934007495,   0.2007763273, ... 
          0.0569563049,  -0.0863731914,  -0.0884070159,  -0.0275717347, ... 
         -0.0041019029,  -0.0069099413,  -0.0087926541,  -0.0231274724, ... 
          0.0318964421 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Nh2_coef.m"; fail; fi

cat > test_Ng2_coef.m << 'EOF'
Ng2 = [   0.6177992263,  -0.4996333154,   0.3319981671,   0.5307796886, ... 
          0.3053385308,   0.0489459540,  -0.0511055405,  -0.0471352816, ... 
         -0.0406865264,  -0.0476517505,  -0.0375376045,  -0.0034500095, ... 
          0.0226209507,   0.0221365148,   0.0067642483,  -0.0039906111, ... 
         -0.0046293550 ];
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
