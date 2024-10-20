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
schurOneMscale.m tf2schurOneMlattice.m local_max.m x2tf.m print_polynomial.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
qroots.m \
qzsolve.oct bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
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
k_min = [     -864,     1152,     -156,     -648, ... 
               352,      496,     -344,     -424, ... 
               584,     -508,       24 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [        8,     -224,     -624,     -272, ... 
                64,       74,      -32,       -8, ... 
                18,      -26,       -3,       -4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.kk.ok << 'EOF'
kk_min = [     -576,       10,      176,       56, ... 
                260,     -167,      236,     -200, ... 
                 96,      -48 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk.ok"; fail; fi

cat > test.ck.ok << 'EOF'
ck_min = [     -272,        0,       84,        0, ... 
                  5,        0,       22,        0, ... 
                 37,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ck.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 0.0000142 & & \\
12-bit 3-signed-digit(Ito)&  0.000316 & 91 & 53 \\
12-bit 3-signed-digit(SOCP-relax) &  0.000195 & 91 & 53 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

strn="socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test"

diff -Bb test.k.ok $strn"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $strn"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test.cost.ok $strn"_kc_min_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
