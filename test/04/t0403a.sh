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
cat > test_k1_coef.m << 'EOF'
k1 = [  -0.0114531183,   0.5787677309,   0.0175664228,  -0.1439299898, ... 
        -0.0035078947,   0.0566943541,   0.0088835253,  -0.0263953543, ... 
        -0.0039520831,   0.0115148917 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_epsilon1_coef.m << 'EOF'
epsilon1 = [  1,  1, -1,  1, ... 
              1, -1, -1,  1, ... 
              1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [   0.5763870249,   0.3013659723,  -0.0570422623,  -0.0856595826, ... 
         0.0510995682,   0.0334174162,  -0.0413339866,  -0.0097645806, ... 
         0.0390566050,  -0.0172486603,  -0.0137483563,   0.0080838138, ... 
         0.0102035778,  -0.0087557840,  -0.0042268483,   0.0071139305, ... 
         0.0012792526,  -0.0097372819,   0.0079074760,   0.0004107953, ... 
        -0.0006748690 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [  -0.6686047283,  -0.2726256006,   0.1315797803,   0.0041060339, ... 
        -0.0655607334,   0.0482344009,   0.0043901690,  -0.0363187120, ... 
         0.0295360056,  -0.0033522210,  -0.0175655855,   0.0128412607, ... 
         0.0026217058,  -0.0109989308,   0.0078792060,   0.0016974330, ... 
        -0.0073779448,   0.0065728642,  -0.0018098297,  -0.0031172859, ... 
         0.0012996335 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=schurOneMAPlattice_frm_socp_slb_test
for coef in k1 epsilon1 u1 v1 ; do
    diff test_$coef"_coef.m" $nstr"_"$coef"_coef.m"
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass


