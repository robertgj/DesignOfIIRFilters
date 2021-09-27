#!/bin/sh

prog=schurOneMAPlattice_frm_socp_slb_test.m

depends="schurOneMAPlattice_frm_socp_slb_test.m test_common.m \
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
k1 = [  -0.0114936698,   0.5789998610,   0.0170167569,  -0.1439045357, ... 
        -0.0037549623,   0.0566758729,   0.0087053115,  -0.0264004779, ... 
        -0.0039542388,   0.0115691715 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_epsilon1_coef.m << 'EOF'
epsilon1 = [  1,  1, -1,  1, ... 
              1, -1, -1,  1, ... 
              1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [   0.5763227211,   0.3013342060,  -0.0565599260,  -0.0857729256, ... 
         0.0511357697,   0.0333887702,  -0.0412581392,  -0.0101472511, ... 
         0.0390848433,  -0.0171349721,  -0.0135968308,   0.0078578009, ... 
         0.0102802121,  -0.0087101015,  -0.0042447045,   0.0070806651, ... 
         0.0014469705,  -0.0098348332,   0.0077977998,   0.0002723638, ... 
        -0.0006019718 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [  -0.6686598407,  -0.2726479081,   0.1315473039,   0.0042329619, ... 
        -0.0655848195,   0.0482061490,   0.0045240460,  -0.0362361561, ... 
         0.0293836062,  -0.0033800527,  -0.0175408378,   0.0127968235, ... 
         0.0026544069,  -0.0109746036,   0.0078184826,   0.0018264202, ... 
        -0.0073343596,   0.0065218903,  -0.0017997422,  -0.0030711804, ... 
         0.0012221344 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=schurOneMAPlattice_frm_socp_slb_test
diff -Bb test_k1_coef.m $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_epsilon1_coef.m $nstr"_epsilon1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon1_coef.m"; fail; fi

diff -Bb test_u1_coef.m $nstr"_u1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi

diff -Bb test_v1_coef.m $nstr"_v1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

