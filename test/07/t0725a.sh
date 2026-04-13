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
../directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_sd_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_Ito_sd_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_min_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_sd_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_Ito_sd_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test_h_min_coef.m \
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
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricP.m \
directFIRnonsymmetricT.m \
directFIRnonsymmetricEsq.m \
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
cat > test_cost.ok << 'EOF'
Floating point &0.004918 & 0.40 &32.98 &0.001001 &0.160 &&\\
Signed-Digit &0.006054 & 0.36 &32.55 &0.003693 &0.213 &87&57\\
Signed-Digit(Ito)&0.005174 & 0.33 &30.58 &0.002729 &0.191 &79&49\\
Branch-and-bound &0.006743 & 0.46 &32.44 &0.002091 &0.166 &86&56\\
SOCP-relaxation &0.005259 & 0.26 &30.45 &0.003907 &0.216 &86&57\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

cat > test_h_min_cost.ok << 'EOF'
Floating-point FIR &0.003243 & 1.00 &29.98 &0.000197 &0.014 &&\\
Signed-digit FIR &0.003017 & 0.95 &29.16 &0.000679 &0.021 &76&46\\
Signed-digit(Ito) FIR&0.003318 & 1.00 &29.26 &0.001207 &0.028 &74&44\\
SOCP-relaxation FIR &0.003432 & 1.00 &29.02 &0.001437 &0.025 &73&43\\
Branch-and-bound FIR &0.003086 & 1.00 &29.02 &0.000805 &0.013 &73&43\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_min_cost.ok"; fail; fi

cat > test_Schur_FIR_cost.ok << 'EOF'
Floating-point Schur &0.004918 & 0.40 &32.98 &0.001001 &0.160 &&\\
Floating-point FIR &0.003243 & 1.00 &29.98 &0.000197 &0.014 &&\\
SOCP-relax. Schur &0.005259 & 0.26 &30.45 &0.003907 &0.216 &86&57\\
SOCP-relax. FIR&0.003432 & 1.00 &29.02 &0.001437 &0.025 &73&43\\
B-and-B Schur&0.006743 & 0.46 &32.44 &0.002091 &0.166 &86&56\\
B-and-B FIR&0.003086 & 1.00 &29.02 &0.000805 &0.013 &73&43\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Schur_FIR_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="comparison_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test"

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_cost.ok"; fail; fi

diff -Bb test_h_min_cost.ok $nstr"_h_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_h_min_cost.ok"; fail; fi

diff -Bb test_Schur_FIR_cost.ok $nstr"_Schur_FIR_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_Schur_FIR_cost.ok"; fail; fi

#
# this much worked
#
pass
