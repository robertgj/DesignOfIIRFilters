#!/bin/sh

prog=socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test.m
depends="\
test/socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test.m \
../schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_epsilon0_coef.m \
../schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_k2_coef.m \
../schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_c2_coef.m \
../schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_kk2_coef.m \
../schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_ck2_coef.m \
test_common.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m \
schurOneMlatticePipelineddAsqdw.m \
schurOneMlatticePipelinedEsq.m \
schurOneMlatticePipelined_slb.m \
schurOneMlatticePipelined_slb_constraints_are_empty.m \
schurOneMlatticePipelined_socp_mmse.m \
schurOneMlatticePipelined_slb_exchange_constraints.m \
schurOneMlatticePipelined_slb_set_empty_constraints.m \
schurOneMlatticePipelined_slb_show_constraints.m \
schurOneMlatticePipelined_slb_update_constraints.m \
schurOneMlatticePipelined_allocsd_Lim.m \
schurOneMlatticePipelined_allocsd_Ito.m \
schurOneMlatticePipelined2Abcd.m \
tf2schurOneMlattice.m schurOneMscale.m local_max.m x2tf.m print_polynomial.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
qroots.oct bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
Abcd2H.oct Abcd2tf.oct"

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
k_min = [      352,     1408,    -1256,      760, ... 
              -952,      832,     -544,      384, ... 
               -24,     -144,      -92 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [      544,     -432,    -2208,      -64, ... 
                60,     -104,       16,       29, ... 
               -16,       20,       -3,       -2 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.kk.ok << 'EOF'
kk_min = [      896,     -668,     -330,     -140, ... 
                 -1,       72,      146,      -80, ... 
                188,       76 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk.ok"; fail; fi

cat > test.ck.ok << 'EOF'
ck_min = [     -160,        0,      -96,        0, ... 
                -64,        0,       24,        0, ... 
                 10,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ck.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 6.9797e-05 & & \\
12-bit 3-signed-digit(Ito)& 1.7284e-04 & 90 & 52 \\
12-bit 3-signed-digit(SOCP-relax) & 1.3528e-04 & 90 & 52 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test"

diff -Bb test.k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test.kk.ok $nstr"_kk_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.kk.ok"; fail; fi

diff -Bb test.ck.ok $nstr"_ck_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.ck.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_kc_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
