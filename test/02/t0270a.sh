#!/bin/sh

prog=socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.m
depends="socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.m \
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
schurOneMlattice2H.oct complex_zhong_inverse.oct SeDuMi_1_3/"

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
cat > test_12_nbits_cost.ok << 'EOF'
Exact & 0.000655 & & \\
12-bit 2-signed-digit(Lim)& 0.001206 & 41 & 19 \\
12-bit 2-signed-digit(SOCP-relax) & 0.001701 & 41 & 19 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_cost.ok"; fail; fi

cat > test_12_nbits_k_min.ok << 'EOF'
k_min = [    -1152,     -272,     -112,      -32, ... 
               -16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_k_min.ok"; fail; fi

cat > test_12_nbits_u_min.ok << 'EOF'
u_min = [       -1,       -4,      -14,      -24, ... 
               -64,      -72,     -104,     -116, ... 
               901 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_u_min.ok"; fail; fi

cat > test_12_nbits_v_min.ok << 'EOF'
v_min = [       16,       10,       14,        4, ... 
               -16,      -64,     -164,     -641 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_v_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test_out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


nstr="socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test"
diff -Bb test_12_nbits_cost.ok $nstr"_kuv_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_cost.ok"; fail; fi

diff -Bb test_12_nbits_k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_k_min.ok"; fail; fi

diff -Bb test_12_nbits_u_min.ok $nstr"_u_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_u_min.ok"; fail; fi

diff -Bb test_12_nbits_v_min.ok $nstr"_v_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_v_min.ok"; fail; fi

#
# this much worked
#
pass
