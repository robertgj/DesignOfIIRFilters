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
direct_form_scale.m qroots.oct \
minphase.oct Abcd2H.oct complementaryFIRdecomp.oct"

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
k2 = [   0.9842521953,   0.9842498484,   0.9842602489,   0.9842704725, ... 
         0.9842498865,   0.9842445588,   0.9842987526,   0.9842846093, ... 
         0.9842006645,   0.9841683462,   0.9842643106,   0.9842157223, ... 
         0.7937021098,   0.9511291357,   0.9842516171,   0.9842525009, ... 
         0.1507825641 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_khat2_coef.m << 'EOF'
khat2 = [  -0.0292668646,   0.0187545505,   0.0568344495,   0.1147348424, ... 
            0.0968778969,   0.0157337587,  -0.0640880981,  -0.1377081627, ... 
           -0.2980293064,  -0.4903828663,  -0.3057689627,   0.3301758422, ... 
            0.7963064981,   0.4849169574,  -0.0882340894,  -0.2837692212, ... 
            0.9841058906 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_khat2_coef.m"; fail; fi

cat > test_Nh2_coef.m << 'EOF'
Nh2 = [   0.0911397993,   0.0712050260,  -0.0742724938,  -0.1976600209, ... 
         -0.2023266597,  -0.0093627511,   0.2011486074,   0.2123052618, ... 
          0.0498000743,  -0.0830136471,  -0.0854014230,  -0.0276465944, ... 
         -0.0030211824,  -0.0191910084,  -0.0098009613,  -0.0315896309, ... 
          0.0176875867 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Nh2_coef.m"; fail; fi

cat > test_Ng2_coef.m << 'EOF'
Ng2 = [   0.5948380958,  -0.6808502476,   0.3900619722,   0.6237745659, ... 
          0.3966657406,   0.1381185827,   0.0163974718,  -0.0198801057, ... 
         -0.0464546913,  -0.0662157183,  -0.0531743715,  -0.0147858742, ... 
          0.0154999340,   0.0192495021,   0.0088347845,  -0.0003791168, ... 
         -0.0027100536 ];
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
