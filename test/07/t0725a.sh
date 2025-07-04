#!/bin/sh

prog=comparison_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m

depends="test/comparison_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef.m \
../branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test_k_min_coef.m \
../branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test_c_min_coef.m \
../socp_relaxation_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test_k_min_coef.m \
../socp_relaxation_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test_c_min_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Ito.m \
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
Exact &3.39e-03& -0.16&-33.99&1.00e-03&1.00e-01&&\\
Signed-Digit & 9.41e-03 &  -0.29 & -31.39 & 7.30e-03 & 2.18e-01 &88&57\\
Signed-Digit(Ito) &4.28e-03& -0.26&-30.77&4.05e-03&1.90e-01&81&50\\
Branch-and-bound &4.03e-03& -0.24&-33.60&2.04e-03&1.32e-01&89&58\\
SOCP-relaxation &4.44e-03& -0.26&-32.04&2.30e-03&1.44e-01&81&50\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="comparison_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test"

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
