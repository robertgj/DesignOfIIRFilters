#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_socp_slb_test.m

depends="schurOneMAPlattice_frm_hilbert_socp_slb_test.m test_common.m \
schurOneMAPlattice_frm_hilbert_socp_mmse.m \
schurOneMAPlattice_frm_hilbert_slb.m \
schurOneMAPlattice_frm_hilbert_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_hilbert_slb_exchange_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_show_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_update_constraints.m \
schurOneMAPlattice_frm_hilbert_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertT.m \
schurOneMAPlattice_frm_hilbertAsq.m schurOneMAPlattice_frm_hilbertP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m H2Asq.m H2P.m H2T.m \
schurOneMscale.m local_max.m print_polynomial.m print_pole_zero.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct SeDuMi_1_3"

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
cat > test_r2_coef.m << 'EOF'
r2 = [   1.0000000000,  -0.4873336778,  -0.1066812904,  -0.0420127524, ... 
        -0.0168502548,  -0.0087697088 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r2_coef.m"; fail; fi

cat > test_k2_coef.m << 'EOF'
k2 = [  -0.5737912482,  -0.1357861405,  -0.0532745521,  -0.0211256540, ... 
        -0.0087697088 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_epsilon2_coef.m << 'EOF'
epsilon2 = [ -1,  1,  1,  1, ... 
              1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2_coef.m"; fail; fi

cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0009005864,  -0.0025457761,  -0.0071130803,  -0.0128019220, ... 
        -0.0309485917,  -0.0343335606,  -0.0517736811,  -0.0570207655, ... 
         0.4398895843 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi

cat > test_v2_coef.m << 'EOF'
v2 = [   0.0065311035,   0.0043827833,   0.0072166026,   0.0020996443, ... 
        -0.0078831931,  -0.0311746387,  -0.0808425030,  -0.3143749022 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_r2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r2_coef.m"; fail; fi

diff -Bb test_k2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2_coef.m"; fail; fi

diff -Bb test_epsilon2_coef.m \
     schurOneMAPlattice_frm_hilbert_socp_slb_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2_coef.m"; fail; fi

diff -Bb test_u2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_u2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u2_coef.m"; fail; fi

diff -Bb test_v2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_v2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v2_coef.m"; fail; fi

#
# this much worked
#
pass

