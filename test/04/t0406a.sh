#!/bin/sh

prog=socp_relaxation_schurOneMAPlattice_frm_12_nbits_test.m
depends="socp_relaxation_schurOneMAPlattice_frm_12_nbits_test.m \
../schurOneMAPlattice_frm_socp_slb_test_k1_coef.m \
../schurOneMAPlattice_frm_socp_slb_test_epsilon1_coef.m \
../schurOneMAPlattice_frm_socp_slb_test_p1_coef.m \
../schurOneMAPlattice_frm_socp_slb_test_u1_coef.m \
../schurOneMAPlattice_frm_socp_slb_test_v1_coef.m \
test_common.m schurOneMAPlattice_frm_socp_mmse.m \
schurOneMAPlattice_frm_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_slb_exchange_constraints.m \
schurOneMAPlattice_frm_slb_update_constraints.m \
schurOneMAPlattice_frm_slb_show_constraints.m \
schurOneMAPlattice_frm_slb.m \
schurOneMAPlattice_frm_allocsd_Ito.m \
schurOneMAPlattice_frm_allocsd_Lim.m \
schurOneMAPlattice_frm.m \
schurOneMAPlattice_frmEsq.m schurOneMAPlattice_frmAsq.m \
schurOneMAPlattice_frmP.m schurOneMAPlattice_frmT.m  \
schurOneMAPlatticeT.m schurOneMAPlatticeP.m schurOneMAPlattice2Abcd.m \
bin2SDul.m Abcd2tf.m schurOneMscale.m H2Asq.m H2T.m H2P.m flt2SD.m \
x2nextra.m local_max.m print_polynomial.m SDadders.m \
schurOneMAPlattice2H.oct schurdecomp.oct schurexpand.oct \
bin2SD.oct bitflip.oct bin2SPT.oct schurOneMlattice2Abcd.oct \
schurOneMlattice2H.oct complex_zhong_inverse.oct"

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
cat > test_12_nbits_cost.ok << 'EOF'
Exact & 0.001667 & & \\
12-bit 3-signed-digit(Lim)& 0.002216 & 119 & 68 \\
12-bit 3-signed-digit(SOCP-relax) & 0.001414 & 128 & 78 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_cost.ok"; fail; fi

cat > test_12_nbits_k_allocsd.ok << 'EOF'
k_allocsd_digits = [  2,  4,  3,  4, ... 
                      2,  4,  4,  4, ... 
                      2,  4 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_k_allocsd.ok";fail;fi

cat > test_12_nbits_u_allocsd.ok << 'EOF'
u_allocsd_digits = [  5,  5,  3,  3, ... 
                      4,  2,  4,  4, ... 
                      4,  2,  4,  4, ... 
                      3,  3,  2,  1, ... 
                      1,  3,  3,  1, ... 
                      0 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_u_allocsd.ok";fail;fi

cat > test_12_nbits_v_allocsd.ok << 'EOF'
v_allocsd_digits = [  5,  4,  4,  2, ... 
                      4,  3,  3,  4, ... 
                      4,  1,  4,  4, ... 
                      2,  1,  3,  2, ... 
                      2,  3,  3,  2, ... 
                      2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_v_allocsd.ok";fail;fi

cat > test_12_nbits_k_min.ok << 'EOF'
k_min = [      -24,     1186,       35,     -294, ... 
                -8,      117,       17,      -53, ... 
                -8,       22 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_k_min.ok"; fail; fi

cat > test_12_nbits_epsilon_min.ok << 'EOF'
epsilon_min = [  1,  1, -1,  1, ... 
                 1, -1, -1,  1, ... 
                 1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_epsilon_min.ok"; \
                      fail; fi

cat > test_12_nbits_u_min.ok << 'EOF'
u_min = [     1179,      617,     -116,     -176, ... 
               105,       68,      -85,      -20, ... 
                79,      -36,      -28,       17, ... 
                21,      -18,       -9,       16, ... 
                 2,      -20,       16,        0, ... 
                 0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_u_min.ok"; fail; fi

cat > test_12_nbits_v_min.ok << 'EOF'
v_min = [    -1368,     -558,      269,        9, ... 
              -133,      100,        8,      -75, ... 
                59,       -8,      -36,       27, ... 
                 4,      -16,       14,        5, ... 
               -15,       12,       -5,       -5, ... 
                 3 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_v_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMAPlattice_frm_12_nbits_test"
diff -Bb test_12_nbits_cost.ok $nstr"_kuv_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_cost.ok"; fail; fi

diff -Bb test_12_nbits_k_allocsd.ok $nstr"_k_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_k_allocsd.ok"; fail; fi

diff -Bb test_12_nbits_u_allocsd.ok $nstr"_u_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_u_allocsd.ok"; fail; fi

diff -Bb test_12_nbits_v_allocsd.ok $nstr"_v_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_v_allocsd.ok"; fail; fi

diff -Bb test_12_nbits_k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_k_min.ok"; fail; fi

diff -Bb test_12_nbits_epsilon_min.ok $nstr"_epsilon_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_epsilon_min.ok"; \
                      fail; fi

diff -Bb test_12_nbits_u_min.ok $nstr"_u_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_u_min.ok"; fail; fi

diff -Bb test_12_nbits_v_min.ok $nstr"_v_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_v_min.ok"; fail; fi

#
# this much worked
#
pass
