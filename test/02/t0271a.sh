#!/bin/sh

prog=branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.m
depends="test/branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.m \
../schurOneMAPlattice_frm_hilbert_socp_slb_test_k2_coef.m \
../schurOneMAPlattice_frm_hilbert_socp_slb_test_epsilon2_coef.m \
../schurOneMAPlattice_frm_hilbert_socp_slb_test_p2_coef.m \
../schurOneMAPlattice_frm_hilbert_socp_slb_test_u2_coef.m \
../schurOneMAPlattice_frm_hilbert_socp_slb_test_v2_coef.m \
test_common.m schurOneMAPlattice_frm_hilbert_socp_mmse.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_hilbert_slb_exchange_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_update_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_show_constraints.m \
schurOneMAPlattice_frm_hilbert_slb.m \
schurOneMAPlattice_frm_hilbert_allocsd_Ito.m \
schurOneMAPlattice_frm_hilbert_allocsd_Lim.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertAsq.m \
schurOneMAPlattice_frm_hilbertP.m schurOneMAPlattice_frm_hilbertT.m  \
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
Exact & 0.000656 & & \\
12-bit 2-signed-digit&0.001686 & 40 & 18 \\
12-bit 2-signed-digit(branch-and-bound)&0.001387 & 40 & 19 \\
12-bit 2-signed-digit(remez)&0.005131 & 73 & 33 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_cost.ok"; fail; fi

cat > test_12_nbits_k_min.ok << 'EOF'
k_min = [    -1152,     -264,      -96,      -36, ... 
               -12 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_k_min.ok"; fail; fi

cat > test_12_nbits_u_min.ok << 'EOF'
u_min = [        0,       -3,      -16,      -24, ... 
               -63,      -72,     -112,     -120, ... 
               896 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_u_min.ok"; fail; fi

cat > test_12_nbits_v_min.ok << 'EOF'
v_min = [       14,        9,       18,        8, ... 
               -12,      -63,     -160,     -640 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_v_min.ok"; fail; fi

cat > test_12_nbits_k_allocsd.ok << 'EOF'
k_allocsd_digits = [  2,  2,  2,  2, ... 
                      2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_k_allocsd.ok";fail;fi

cat > test_12_nbits_u_allocsd.ok << 'EOF'
u_allocsd_digits = [  2,  2,  2,  2, ... 
                      2,  2,  2,  2, ... 
                      2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_u_allocsd.ok";fail;fi

cat > test_12_nbits_v_allocsd.ok << 'EOF'
v_allocsd_digits = [  2,  2,  2,  2, ... 
                      2,  2,  2,  2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_v_allocsd.ok";fail;fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


nstr="branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test"
diff -Bb test_12_nbits_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_cost.ok"; fail; fi

diff -Bb test_12_nbits_k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_k_min.ok"; fail; fi

diff -Bb test_12_nbits_u_min.ok $nstr"_u_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_u_min.ok"; fail; fi

diff -Bb test_12_nbits_v_min.ok $nstr"_v_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_v_min.ok"; fail; fi

diff -Bb test_12_nbits_k_allocsd.ok $nstr"_k_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_k_allocsd.ok"; fail; fi

diff -Bb test_12_nbits_u_allocsd.ok $nstr"_u_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_u_allocsd.ok"; fail; fi

diff -Bb test_12_nbits_v_allocsd.ok $nstr"_v_allocsd_digits.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_v_allocsd.ok"; fail; fi

#
# this much worked
#
pass
