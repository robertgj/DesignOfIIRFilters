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
Floating point &0.003385 & 0.16 &33.99 &0.001000 &0.100 &&\\
Signed-Digit &0.009413 & 0.29 &31.39 &0.007299 &0.218 &88&57\\
Signed-Digit(Ito)&0.004279 & 0.26 &30.77 &0.004048 &0.190 &81&50\\
Branch-and-bound &0.004031 & 0.24 &33.60 &0.002041 &0.132 &89&58\\
SOCP-relaxation &0.004437 & 0.26 &32.04 &0.002301 &0.144 &81&50\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

cat > test_h_min_cost.ok << 'EOF'
Floating-point FIR &0.003232 & 1.00 &29.99 &0.000143 &0.012 &&\\
Signed-digit FIR &0.003039 & 0.97 &29.02 &0.000923 &0.020 &81&50\\
Signed-digit(Ito) FIR&0.003065 & 1.01 &28.79 &0.001101 &0.017 &76&45\\
SOCP-relaxation FIR &0.003165 & 0.99 &28.19 &0.001429 &0.022 &76&45\\
Branch-and-bound FIR &0.002993 & 1.00 &28.20 &0.001256 &0.021 &76&45\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_min_cost.ok"; fail; fi

cat > test_Schur_FIR_cost.ok << 'EOF'
Floating-point Schur &0.003385 & 0.16 &33.99 &0.001000 &0.100 &&\\
Floating-point FIR &0.003232 & 1.00 &29.99 &0.000143 &0.012 &&\\
SOCP-relax. Schur &0.004437 & 0.26 &32.04 &0.002301 &0.144 &81&50\\
SOCP-relax. FIR&0.003165 & 0.99 &28.19 &0.001429 &0.022 &76&45\\
B-and-B Schur&0.004031 & 0.24 &33.60 &0.002041 &0.132 &89&58\\
B-and-B FIR&0.002993 & 1.00 &28.20 &0.001256 &0.021 &76&45\\
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
