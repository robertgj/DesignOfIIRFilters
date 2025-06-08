#!/bin/sh

prog=comparison_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m

depends="test/comparison_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef.m \
../branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_k_min_coef.m \
../branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_c_min_coef.m \
../socp_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_k_min_coef.m \
../socp_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_epsilon_min_coef.m \
../socp_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_c_min_coef.m \
../pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_k_min_coef.m \
../pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test_c_min_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
qroots.oct bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMlattice2H.oct"

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
cat > test.cost.ok << 'EOF'
Exact & 2.5139 & 4.50e-04 & 3.51e-03 & 3.03e-04 & 3.00e-03 & & \\
Branch-and-bound & 2.5134 & 9.56e-04 & 5.82e-03 & 5.26e-04 & 2.87e-03 & 36 & 20 \\
SOCP-relaxation & 2.5152 & 6.22e-04 & 6.24e-03 & 6.15e-04 & 4.64e-03 & 37 & 21 \\
POP-relaxation & 2.5138 & 7.81e-04 & 4.51e-03 & 5.84e-04 & 5.58e-03 & 40 & 24 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="comparison_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test"

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
