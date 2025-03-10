#!/bin/sh

prog=socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test.m
depends="\
test/socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_test_k2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_lowpass_differentiator_test_c2_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlattice_allocsd_Ito.m \
local_max.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
schurOneMlatticeFilter.m flt2SD.m x2nextra.m bin2SDul.m SDadders.m qroots.oct \
bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
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
cat > test.k.ok << 'EOF'
k_min = [      696,     1192,     -808,      705, ... 
              -604,      464,     -332,      196, ... 
              -108,       40,      -15 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [      330,     -482,    -1344,       69, ... 
               132,      -98,       32,        2, ... 
               -20,       12,       -8,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 0.0005298 & & \\
12-bit 3-signed-digit(Lim)&  0.000723 & 64 & 41 \\
12-bit 3-signed-digit(SOCP-relax) &  0.000861 & 63 & 40 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test"

diff -Bb test.k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_kc_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
