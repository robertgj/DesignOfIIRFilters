#!/bin/sh

prog=complementaryFIRlattice_socp_slb_bandpass_test.m

depends="test/complementaryFIRlattice_socp_slb_bandpass_test.m test_common.m \
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
cat > test_exp_k2_coef.m << 'EOF'
exp_k2 = [     0.9843749874,   0.9843631757,   0.9843749817,   0.9843749784, ... 
               0.9843459672,   0.9843565254,   0.9843634536,   0.9843597582, ... 
               0.9843749877,   0.9616092364,   0.9783249979,   0.9843523723, ... 
               0.8651000806,   0.9391120075,   0.9843712627,   0.9843749891, ... 
               0.1431375883 ]';
complementaryFIRlattice_socp_slb_bandpass_test_k2_coef;
tol=1e-6;
if norm(exp_k2-k2)>tol
  error("norm(exp_k2-k2)(%g*tol) > tol",norm(exp_k2-k2)/tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_k2_coef.m"; fail; fi

cat > test_exp_khat2_coef.m << 'EOF'
exp_khat2 = [ -0.0468090736,  -0.0110913025,   0.0396599420,   0.0865990218, ... 
               0.0779802487,   0.0419015507,   0.0369863739,   0.0160169196, ... 
              -0.1702565164,  -0.4765225365,  -0.4461363669,   0.1095851846, ... 
               0.6318802083,   0.5215848312,   0.0125879244,  -0.2158720334, ... 
               0.9843107113 ]';
complementaryFIRlattice_socp_slb_bandpass_test_khat2_coef;
tol=1e-6;
if norm(exp_khat2-khat2)>tol
  error("norm(exp_khat2-khat2)(%g*tol) > tol",norm(exp_khat2-khat2)/tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_khat2_coef.m"; fail; fi

cat > test_exp_Nh2_coef.m << 'EOF'
exp_Nh2 =    [ 0.0905516697,   0.0672322315,  -0.0672208463,  -0.2162026902, ... 
              -0.2047023001,  -0.0057471936,   0.1918350844,   0.2011736026, ... 
               0.0531978852,  -0.0805104681,  -0.0901114111,  -0.0324363609, ... 
               0.0009615963,  -0.0060123457,  -0.0150377974,  -0.0165810988, ... 
               0.0296104123 ];
complementaryFIRlattice_socp_slb_bandpass_test_Nh2_coef;
tol=1e-6;
if norm(exp_Nh2-Nh2)>tol
  error("norm(exp_Nh2-Nh2)(%g*tol) > tol",norm(exp_Nh2-Nh2)/tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_Nh2_coef.m"; fail; fi

cat > test_exp_Ng2_coef.m << 'EOF'
exp_Ng2 = [  0.6226944265,  -0.4965749027,   0.3304626864,   0.5303746308, ... 
             0.3051396692,   0.0470369856,  -0.0545580660,  -0.0503002222, ... 
            -0.0409730191,  -0.0462269555,  -0.0353527180,  -0.0026893333, ... 
             0.0226820616,   0.0217552274,   0.0060936835,  -0.0042196293, ... 
            -0.0043059198 ];
complementaryFIRlattice_socp_slb_bandpass_test_Ng2_coef;
tol=1e-6;
if norm(exp_Ng2-Ng2)>tol
  error("norm(exp_Ng2-Ng2)(%g*tol) > tol",norm(exp_Ng2-Ng2)/tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_Ng2_coef.m"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

for coef in k2 khat2 Nh2 Ng2 ; do
    octave --no-gui -q test_exp_$coef"_coef.m" >test.out 2>&1
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass
