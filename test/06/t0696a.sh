#!/bin/sh

prog=branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m

depends="\
test/branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_p2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlatticeFilter.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2Abcd.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m flt2SD.m bin2SDul.m SDadders.m x2nextra.m \
qroots.oct schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct Abcd2tf.oct \
bin2SD.oct bin2SPT.oct"

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
cat > test_k.ok << 'EOF'
k_min = [        0,      432,        0,      -57, ... 
                 0,       18,        0,       -6, ... 
                 0,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2.ok"; fail; fi

cat > test_c.ok << 'EOF'
c_min = [      -49,     -446,     -576,      -69, ... 
               142,      -25,      -46,       27, ... 
                 6,      -10,        2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c2.ok"; fail; fi

cat > test_cost.tab.ok << 'EOF'
Exact & 6.4220e-06 & & \\
12-bit 3-signed-digit&1.1056e-05 & 38 & 22 \\
12-bit 3-signed-digit(Lim)&1.1056e-05 & 38 & 22 \\
12-bit 3-signed-digit(branch-and-bound)&7.4922e-06 & 39& 23\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.tab.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test"

diff -Bb test_k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_k.ok"; fail; fi

diff -Bb test_c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_c.ok"; fail; fi

diff -Bb test_cost.tab.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_cost.tab.ok"; fail; fi

#
# this much worked
#
pass
