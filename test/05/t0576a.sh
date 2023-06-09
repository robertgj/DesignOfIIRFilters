#!/bin/sh

prog=socp_relaxation_schurOneMAPlattice_frm_16_nbits_test.m
depends="test/socp_relaxation_schurOneMAPlattice_frm_16_nbits_test.m \
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
cat > test_16_nbits_cost.ok << 'EOF'
Exact & 0.001693 & & \\
16-bit 3-signed-digit(Ito)& 0.002048 & 147 & 95 \\
16-bit 3-signed-digit(SOCP-relax) & 0.001230 & 143 & 91 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_cost.ok"; fail; fi

cat > test_16_nbits_k_allocsd.ok << 'EOF'
k_allocsd_digits = [  3,  5,  2,  3, ... 
                      2,  2,  1,  3, ... 
                      2,  6 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_k_allocsd.ok";fail;fi

cat > test_16_nbits_u_allocsd.ok << 'EOF'
u_allocsd_digits = [  5,  6,  4,  4, ... 
                      3,  2,  5,  1, ... 
                      3,  2,  6,  1, ... 
                      2,  3,  2,  2, ... 
                      1,  2,  2,  2, ... 
                      1 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_u_allocsd.ok";fail;fi

cat > test_16_nbits_v_allocsd.ok << 'EOF'
v_allocsd_digits = [  6,  4,  3,  2, ... 
                      3,  4,  2,  3, ... 
                      6,  2,  3,  6, ... 
                      3,  4,  2,  1, ... 
                      2,  2,  6,  2, ... 
                      2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_v_allocsd.ok";fail;fi

cat > test_16_nbits_k_min.ok << 'EOF'
k_min = [     -572,    19136,      480,    -4672, ... 
              -288,     1920,      256,     -832, ... 
              -224,      351 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_k_min.ok"; fail; fi

cat > test_16_nbits_epsilon_min.ok << 'EOF'
epsilon_min = [  1,  1, -1,  1, ... 
                 1, -1, -1,  1, ... 
                 1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_epsilon_min.ok"; \
                      fail; fi

cat > test_16_nbits_u_min.ok << 'EOF'
u_min = [    18896,     9861,    -1880,    -2752, ... 
              1664,     1088,    -1402,     -256, ... 
              1264,     -576,     -447,      256, ... 
               320,     -304,     -136,      240, ... 
                16,     -320,      264,       10, ... 
               -32 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_u_min.ok"; fail; fi

cat > test_16_nbits_v_min.ok << 'EOF'
v_min = [   -21872,    -8956,     4320,      144, ... 
             -2160,     1576,      160,    -1184, ... 
               920,      -80,     -592,      445, ... 
                96,     -374,      260,       64, ... 
              -240,      192,      -61,     -112, ... 
                72 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_16_nbits_v_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMAPlattice_frm_16_nbits_test"
diff -Bb test_16_nbits_cost.ok $nstr"_kuv_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_cost.ok"; fail; fi

diff -Bb test_16_nbits_k_allocsd.ok $nstr"_k_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_k_allocsd.ok"; fail; fi

diff -Bb test_16_nbits_u_allocsd.ok $nstr"_u_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_u_allocsd.ok"; fail; fi

diff -Bb test_16_nbits_v_allocsd.ok $nstr"_v_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_v_allocsd.ok"; fail; fi

diff -Bb test_16_nbits_k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_k_min.ok"; fail; fi

diff -Bb test_16_nbits_epsilon_min.ok $nstr"_epsilon_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_epsilon_min.ok"; \
                      fail; fi

diff -Bb test_16_nbits_u_min.ok $nstr"_u_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_u_min.ok"; fail; fi

diff -Bb test_16_nbits_v_min.ok $nstr"_v_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_16_nbits_v_min.ok"; fail; fi

#
# this much worked
#
pass
