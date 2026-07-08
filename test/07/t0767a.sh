#!/bin/sh

prog=comparison_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test.m

depends="test/comparison_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test.m \
../parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Da1_coef.m \
../parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Db1_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k0_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k0_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k0_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k0_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_allocsd_digits.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_allocsd_digits.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_allocsd_digits.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_allocsd_digits.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_Lim_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_Lim_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_Lim_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_Lim_sd_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_min_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_min_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_min_coef.m \
../socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_min_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k0_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k0_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k0_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k0_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_allocsd_digits.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_allocsd_digits.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_allocsd_digits.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_allocsd_digits.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_Lim_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_Lim_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_Lim_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_Lim_sd_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A1k_min_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_A2k_min_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa1k_min_coef.m \
../branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test_Aaa2k_min_coef.m \
../directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_Lim_sd_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_allocsd_digits.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_sd_coef.m \
../socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_min_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_Lim_sd_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_allocsd_digits.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_sd_coef.m \
../branch_bound_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test_h_min_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedP.m \
schurOneMPAlatticeDoublyPipelinedT.m \
schurOneMPAlatticeDoublyPipelineddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedP.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedT.m \
schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq.m \
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricP.m \
directFIRnonsymmetricT.m \
directFIRnonsymmetricEsq.m \
directFIRnonsymmetric_allocsd_Lim.m \
print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m tf2pa.m \
flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
schurOneMAPlattice2Abcd.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMAPlatticeDoublyPipelined2H.oct \
qroots.oct bin2SD.oct bin2SPT.oct Abcd2H.oct Abcd2tf.oct \
schurdecomp.oct schurexpand.oct schurOneMAPlattice2H.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct \
spectralfactor.oct complex_zhong_inverse.oct"

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
Floating point &0.000537 & 0.20 & 9.80 &0.000095 &0.008 &&\\
Signed-Digit &0.001127 & 0.22 &10.08 &0.003770 &0.068 &42&27\\
Signed-Digit(Lim)&0.000613 & 0.20 & 9.83 &0.000935 &0.024 &42&28\\
Branch-and-bound &0.000528 & 0.19 &20.07 &0.000292 &0.020 &43&29\\
SOCP-relaxation &0.000569 & 0.20 &20.03 &0.000446 &0.033 &43&29\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

cat > test_h_min_cost.ok << 'EOF'
Floating-point FIR &0.003223 & 1.00 &29.98 &0.000148 &0.008 &&\\
Signed-digit FIR &0.003024 & 0.95 &29.18 &0.000619 &0.025 &70&40\\
Signed-digit(Lim) FIR&0.003347 & 1.00 &29.56 &0.000905 &0.017 &75&46\\
SOCP-relaxation FIR &0.003239 & 1.00 &29.67 &0.000560 &0.020 &77&48\\
Branch-and-bound FIR &0.003163 & 1.01 &29.01 &0.000808 &0.016 &78&49\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_min_cost.ok"; fail; fi

cat > test_Schur_FIR_cost.ok << 'EOF'
Floating-point Schur &0.000537 & 0.20 & 9.80 &0.000095 &0.008 &&\\
Floating-point FIR &0.003223 & 1.00 &29.98 &0.000148 &0.008 &&\\
SOCP-relax. Schur &0.000569 & 0.20 &20.03 &0.000446 &0.033 &43&29\\
SOCP-relax. FIR&0.003239 & 1.00 &29.67 &0.000560 &0.020 &77&48\\
B-and-B Schur&0.000528 & 0.19 &20.07 &0.000292 &0.020 &43&29\\
B-and-B FIR&0.003163 & 1.01 &29.01 &0.000808 &0.016 &78&49\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Schur_FIR_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="comparison_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test"

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
