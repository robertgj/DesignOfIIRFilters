#!/bin/sh

prog=pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_14_nbits_test.m

depends="test/pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_14_nbits_test.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_p2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef.m \
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
qroots.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2H.oct Abcd2tf.oct \
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
cat > test.k.ok << 'EOF'
k_sd_min = [        0,     5824,        0,     3424, ... 
                    0,     2324,        0,     4121, ... 
                    0,     2751,        0,     3500, ... 
                    0,     2135,        0,     2027, ... 
                    0,      800,        0,      497 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_sd_min = [     -344,      800,     3868,     2208, ... 
                -1416,    -3568,    -2012,     -192, ... 
                 1640,     1280,      256,       32, ... 
                  544,      392,      -16,     -288, ... 
                  -96,      -48,      -48,     -114, ... 
                  -55 ]'/8192;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 1.4062e-03 & -33.99 & & \\
14-bit 4-signed-digit & 1.4114e-03 & -33.27 & 110 & 79 \\
14-bit 4-signed-digit(Ito) & 1.6814e-03 & -33.25 & 94 & 63 \\
14-bit 4-signed-digit(POP min.) & 1.2420e-03 & -32.12 & 96 & 65 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_14_nbits_test"

diff -Bb test.k.ok $nstr"_k_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
