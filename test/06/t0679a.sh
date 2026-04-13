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
k_min = [      112,     1440,    -1460,      838, ... 
              -784,      752,     -528,      456, ... 
                32,     -176,      120 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi
cat > test.c.ok << 'EOF'
c_min = [      800,     -352,    -2336,     -196, ... 
                44,     -144,      -16,       44, ... 
               -23,       93,       -2,       -1 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.kk.ok << 'EOF'
kk_min = [      944,     -592,     -562,     -254, ... 
                -16,      104,      272,      -80, ... 
                191,     -123 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk.ok"; fail; fi

cat > test.ck.ok << 'EOF'
ck_min = [     -384,        0,     -248,        0, ... 
               -144,        0,       16,        0, ... 
                 80,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ck.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 9.6266e-05 & & \\
12-bit 3-signed-digit(Ito)& 1.8914e-04 & 97 & 59 \\
12-bit 3-signed-digit(SOCP-relax) & 1.9461e-04 & 98 & 60 \\
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
