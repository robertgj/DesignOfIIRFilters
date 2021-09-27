#!/bin/sh

prog=branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.m
depends="branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.m test_common.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A1k_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A1p_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A1epsilon_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A2k_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A2epsilon_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_test_A2p_coef.m \
schurOneMPAlattice_allocsd_Lim.m \
schurOneMPAlattice_allocsd_Ito.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m flt2SD.m bin2SDul.m x2nextra.m \
SDadders.m Abcd2tf.m H2Asq.m H2T.m H2P.m tf2schurOneMlattice.m schurOneMscale.m \
bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.m qzsolve.oct"

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
Exact & 0.000194 & & \\
12-bit 3-signed-digit(Ito)& 0.000320 & 62 & 39 \\
12-bit 3-signed-digit(SOCP b-and-b) & 0.000158 & 62 & 39 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_cost.ok"; fail; fi

cat > test_12_nbits_A1k_min.ok << 'EOF'
A1k_min = [     1584,     -168,     -536,     -128, ... 
                -128,      480,     -280,       -4, ... 
                 336,     -316,      112 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_A1k_min.ok"; fail; fi

cat > test_12_nbits_A2k_min.ok << 'EOF'
A2k_min = [      784,     -576,      384,      336, ... 
                 -96,       84,     -398,      352, ... 
                  12,     -360,      298,     -115 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_A2k_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


nstr="branch_bound_schurOneMPAlattice_lowpass_12_nbits_test"
diff -Bb test_12_nbits_cost.ok $nstr"_kmin_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_cost.ok"; fail; fi

diff -Bb test_12_nbits_A1k_min.ok $nstr"_A1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_A1k_min.ok"; fail; fi

diff -Bb test_12_nbits_A2k_min.ok $nstr"_A2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_12_nbits_A2k_min.ok"; fail; fi

#
# this much worked
#
pass
