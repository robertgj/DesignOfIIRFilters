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
k2 = [   0.9843749874,   0.9843631757,   0.9843749817,   0.9843749784, ... 
         0.9843459673,   0.9843565255,   0.9843634536,   0.9843597582, ... 
         0.9843749877,   0.9616092363,   0.9783249999,   0.9843523724, ... 
         0.8651000625,   0.9391119994,   0.9843712626,   0.9843749891, ... 
         0.1431375890 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_khat2_coef.m << 'EOF'
khat2 = [  -0.0468090807,  -0.0110912967,   0.0396599506,   0.0865990302, ... 
            0.0779802534,   0.0419015455,   0.0369863558,   0.0160168973, ... 
           -0.1702565288,  -0.4765225330,  -0.4461363574,   0.1095851999, ... 
            0.6318802295,   0.5215848417,   0.0125879124,  -0.2158720481, ... 
            0.9843107114 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_khat2_coef.m"; fail; fi

cat > test_Nh2_coef.m << 'EOF'
Nh2 = [   0.0905516677,   0.0672322349,  -0.0672208470,  -0.2162026920, ... 
         -0.2047022993,  -0.0057471919,   0.1918350844,   0.2011736015, ... 
          0.0531978852,  -0.0805104663,  -0.0901114106,  -0.0324363626, ... 
          0.0009615960,  -0.0060123426,  -0.0150377967,  -0.0165811069, ... 
          0.0296104160 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Nh2_coef.m"; fail; fi

cat > test_Ng2_coef.m << 'EOF'
Ng2 = [   0.6226944095,  -0.4965749166,   0.3304626930,   0.5303746338, ... 
          0.3051396708,   0.0470369937,  -0.0545580525,  -0.0503002117, ... 
         -0.0409730177,  -0.0462269617,  -0.0353527257,  -0.0026893371, ... 
          0.0226820624,   0.0217552300,   0.0060936851,  -0.0042196294, ... 
         -0.0043059204 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Ng2_coef.m"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="complementaryFIRlattice_socp_slb_bandpass_test"
for coef in k2 khat2 Nh2 Ng2 ; do
    diff -bBw test_$coef"_coef.m" $nstr"_"$coef"_coef.m"
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass
