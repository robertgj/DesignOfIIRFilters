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
k1 = [  -0.0115879256,   0.5789496007,   0.0171003199,  -0.1438674359, ... 
        -0.0038934475,   0.0567913619,   0.0087086840,  -0.0265210293, ... 
        -0.0039628445,   0.0116191923 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_epsilon1_coef.m << 'EOF'
epsilon1 = [  1,  1, -1,  1, ... 
              1, -1, -1,  1, ... 
              1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [   0.5761123722,   0.3016314723,  -0.0567581404,  -0.0858374668, ... 
         0.0512145440,   0.0333390213,  -0.0413687975,  -0.0099257827, ... 
         0.0388621061,  -0.0170073493,  -0.0137808713,   0.0080232863, ... 
         0.0104065135,  -0.0088246506,  -0.0041055374,   0.0070700174, ... 
         0.0013952447,  -0.0097878861,   0.0077313589,   0.0003707355, ... 
        -0.0007119704 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [  -0.6688272807,  -0.2725343095,   0.1315162797,   0.0041501112, ... 
        -0.0655647806,   0.0482545257,   0.0045082029,  -0.0362611064, ... 
         0.0296053068,  -0.0034810284,  -0.0175541142,   0.0127757364, ... 
         0.0026450262,  -0.0110625265,   0.0078693965,   0.0018285724, ... 
        -0.0074061212,   0.0066874716,  -0.0018703680,  -0.0031236291, ... 
         0.0013031427 ]';
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

