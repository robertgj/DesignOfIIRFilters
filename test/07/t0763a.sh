#!/bin/sh

prog=socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test.m
depends="test/socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test.m \
../parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Da1_coef.m \
../parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Db1_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Naa_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Daa_coef.m \
test_common.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_slb.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedP.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedT.m \
schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedEsq.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedP.m \
schurOneMPAlatticeDoublyPipelinedT.m \
schurOneMPAlatticeDoublyPipelineddAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
schurOneMAPlatticeDoublyPipelined2H.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
print_polynomial.m H2T.m H2P.m H2Asq.m H2dAsqdw.m KW.m \
tf2schurOneMlattice.m schurOneMscale.m delayz.m local_max.m tf2pa.m \
flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct Abcd2tf.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct schurOneMAPlattice2H.oct \
spectralfactor.oct Abcd2H.oct Abcd2tf.oct complex_zhong_inverse.oct qroots.oct"

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
cat > test_A1k_min_coef.m << 'EOF'
A1k_min = [      792,     1054,      400,      312 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min_coef.m"; fail; fi

cat > test_A2k_min_coef.m << 'EOF'
A2k_min = [     1496,      290,      832,      968, ... 
                 472,      368 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min_coef.m"; fail; fi

cat > test_Aaa1k_min_coef.m << 'EOF'
Aaa1k_min = [        0,     1812,        0,      273, ... 
                     0,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Aaa1k_min_coef.m"; fail; fi

cat > test_Aaa2k_min_coef.m << 'EOF'
Aaa2k_min = [        0,     1044,        0,        2, ... 
                     0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Aaa2k_min_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased_bandpass_hilbert_12_nbits_test"

diff -Bb test_A1k_min_coef.m $nstr"_A1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_min_coef.m"; fail; fi

diff -Bb test_A2k_min_coef.m $nstr"_A2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_min_coef.m"; fail; fi

diff -Bb test_Aaa1k_min_coef.m $nstr"_Aaa1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Aaa1k_min_coef.m"; fail; fi

diff -Bb test_Aaa2k_min_coef.m $nstr"_Aaa2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Aaa2k_min_coef.m"; fail; fi


#
# this much worked
#
pass

