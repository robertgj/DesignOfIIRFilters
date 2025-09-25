#!/bin/sh

prog=pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m

depends="test/pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_p2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_pop_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMscale.m schurOneMlattice2tf.m \
schurOneMlatticeFilter.m tf2schurOneMlattice.m local_max.m print_polynomial.m \
x2nextra.m H2Asq.m H2T.m H2P.m H2dAsqdw.m flt2SD.m bin2SDul.m SDadders.m \
qroots.oct schurdecomp.oct schurexpand.oct schurOneMlattice2H.oct Abcd2tf.oct \
schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct complex_zhong_inverse.oct"

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
cat > test.k_min.ok << 'EOF'
k_min = [        0,      432,        0,      -57, ... 
                 0,       18,        0,       -6, ... 
                 0,        1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_min.ok"; fail; fi

cat > test.c_min.ok << 'EOF'
c_min = [      -49,     -446,     -576,      -69, ... 
               142,      -25,      -46,       28, ... 
                 6,      -10,        2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_min.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 3.8350e-06 & -49.11 & & \\
12-bit 3-signed-digit & 8.3529e-06 & -48.34 & 38 & 22 \\
12-bit 3-signed-digit(Lim)& 8.3529e-06 & -48.34 & 38 & 22 \\
12-bit 3-signed-digit(POP-relax) & 6.9205e-06 & -47.05 & 38 & 22 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test"

diff -Bb test.k_min.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k_min.ok"; fail; fi

diff -Bb test.c_min.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c_min.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
