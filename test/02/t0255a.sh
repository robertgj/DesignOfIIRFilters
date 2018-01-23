#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_socp_slb_test.m

depends="schurOneMAPlattice_frm_halfband_socp_slb_test.m test_common.m \
schurOneMAPlattice_frm_halfband_socp_mmse.m \
schurOneMAPlattice_frm_halfband_slb.m \
schurOneMAPlattice_frm_halfband_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_halfband_slb_exchange_constraints.m \
schurOneMAPlattice_frm_halfband_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_halfband_slb_show_constraints.m \
schurOneMAPlattice_frm_halfband_slb_update_constraints.m \
schurOneMAPlattice_frm_halfband_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_halfbandEsq.m schurOneMAPlattice_frm_halfbandT.m \
schurOneMAPlattice_frm_halfbandAsq.m schurOneMAPlatticeP.m \
schurOneMAPlatticeT.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m H2T.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
local_max.m print_polynomial.m print_pole_zero.m SeDuMi_1_3/"

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
r2 = [   1.0000000000,   0.4781695233,  -0.1013106483,   0.0357457625, ... 
        -0.0107864868,   0.0016971614 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r2_coef.m"; fail; fi

cat > test_k2_coef.m << 'EOF'
k2 = [   0.5513647985,  -0.1226221784,   0.0414694475,  -0.0115980510, ... 
         0.0016971614 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0009683952,   0.0030679057,  -0.0073782309,   0.0129251195, ... 
        -0.0312931506,   0.0347144107,  -0.0509918159,   0.0564017564, ... 
         0.4410590511 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi

cat > test_v2_coef.m << 'EOF'
v2 = [   0.0069061999,  -0.0046376875,   0.0066901713,  -0.0018175372, ... 
        -0.0088804803,   0.0318048114,  -0.0813024632,   0.3142298607 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_r2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r2_coef.m"; fail; fi

diff -Bb test_k2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2_coef.m"; fail; fi

diff -Bb test_u2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_u2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u2_coef.m"; fail; fi

diff -Bb test_v2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_v2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v2_coef.m"; fail; fi

#
# this much worked
#
pass

