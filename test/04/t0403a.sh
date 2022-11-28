#!/bin/sh

prog=schurOneMAPlattice_frm_socp_slb_test.m

depends="test/schurOneMAPlattice_frm_socp_slb_test.m test_common.m \
../iir_frm_allpass_socp_slb_test_r_coef.m \
../iir_frm_allpass_socp_slb_test_aa_coef.m \
../iir_frm_allpass_socp_slb_test_ac_coef.m \
schurOneMAPlattice_frm_slb.m \
schurOneMAPlattice_frm_socp_mmse.m \
schurOneMAPlattice_frm_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_slb_update_constraints.m \
schurOneMAPlattice_frm_slb_exchange_constraints.m \
schurOneMAPlattice_frm_slb_show_constraints.m \
schurOneMAPlattice_frm_socp_slb_plot.m \
schurOneMAPlattice_frm.m \
schurOneMAPlattice_frmEsq.m schurOneMAPlattice_frmT.m \
schurOneMAPlattice_frmAsq.m schurOneMAPlattice_frmP.m \
schurOneMAPlattice2tf.m tf2schurOneMlattice.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m  \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m local_max.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
print_polynomial.m print_pole_zero.m qroots.m qzsolve.oct"

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
cat > test_exp_k1_coef.m << 'EOF'
exp_k1 = [ -0.0110731477,   0.5786372320,   0.0175276312,  -0.1441823384, ... 
           -0.0035186249,   0.0568556517,   0.0087110222,  -0.0265008201, ... 
           -0.0037440088,   0.0116060049 ]';
schurOneMAPlattice_frm_socp_slb_test_k1_coef;
tol=2e-10;
if max(abs(exp_k1(:)-k1(:)))>tol
   error("max(abs(exp_k1-k1))(%g)>tol(%g)",max(abs(exp_k1(:)-k1(:))),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_k1_coef.m"; fail; fi

cat > test_exp_epsilon1_coef.m << 'EOF'
exp_epsilon1 = [ 1,  1, -1,  1,  1, -1, -1,  1,  1, -1 ]';
schurOneMAPlattice_frm_socp_slb_test_epsilon1_coef;
tol=2e-10;
if max(abs(exp_epsilon1(:)-epsilon1(:)))>tol
   error("max(abs(exp_epsilon1-epsilon1))(%g)>tol(%g)",
         max(abs(exp_epsilon1(:)-epsilon1(:))),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_epsilon1_coef.m"; fail; fi

cat > test_exp_u1_coef.m << 'EOF'
exp_u1 = [  0.5766164415,   0.3012840561,  -0.0569884534,  -0.0856143363, ... 
            0.0512118160,   0.0332018000,  -0.0413897727,  -0.0098675161, ... 
            0.0391459456,  -0.0174705554,  -0.0137287284,   0.0080093289, ... 
            0.0101329905,  -0.0087037536,  -0.0041187016,   0.0070941840, ... 
            0.0012606610,  -0.0097509980,   0.0080763800,   0.0003540275, ... 
           -0.0006555965 ]';
schurOneMAPlattice_frm_socp_slb_test_u1_coef;
tol=2e-10;
if max(abs(exp_u1(:)-u1(:)))>tol
   error("max(abs(exp_u1-u1))(%g)>tol(%g)",
         max(abs(exp_u1(:)-u1(:))),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_u1_coef.m"; fail; fi

cat > test_exp_v1_coef.m << 'EOF'
exp_v1 = [ -0.6682946298,  -0.2727662258,   0.1318030122,   0.0042369182, ... 
           -0.0655691204,   0.0481300985,   0.0045354583,  -0.0361947600, ... 
            0.0293355959,  -0.0031824737,  -0.0176760468,   0.0130074767, ... 
            0.0026377642,  -0.0109024065,   0.0077522747,   0.0018211918, ... 
           -0.0073722341,   0.0065135360,  -0.0018062429,  -0.0031236248, ... 
            0.0012519438  ]';
schurOneMAPlattice_frm_socp_slb_test_v1_coef;
tol=2e-10;
if max(abs(exp_v1(:)-v1(:)))>tol
   error("max(abs(exp_v1-v1))(%g)>tol(%g)",
         max(abs(exp_v1(:)-v1(:))),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

for coef in k1 epsilon1 u1 v1 ; do
    octave --no-gui -q test_exp_$coef"_coef.m" >test.out 2>&1
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass


