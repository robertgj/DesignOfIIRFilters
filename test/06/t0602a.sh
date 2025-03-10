#!/bin/sh

prog=branch_bound_schurOneMlatticePipelined_bandpass_10_nbits_test.m

depends="test/branch_bound_schurOneMlatticePipelined_bandpass_10_nbits_test.m \
../schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m \
test_common.m schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelinedAsq.m schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m schurOneMlatticePipelinedEsq.m \
schurOneMscale.m tf2schurOneMlattice.m local_max.m x2tf.m tf2pa.m \
print_polynomial.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
x2nextra.m SDadders.m Abcd2ng.m KW.m qroots.oct \
Abcd2H.oct schurdecomp.oct schurexpand.oct bin2SPT.oct bin2SD.oct \
Abcd2tf.oct"

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
cat > test_k.ok << 'EOF'
k_min = [        0,      336,        0,      255, ... 
                 0,      176,        0,      216, ... 
                 0,      152,        0,      129, ... 
                 0,       78,        0,       54, ... 
                 0,       19,        0,        8 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k.ok"; fail; fi

cat > test_c.ok << 'EOF'
c_min = [       73,      -14,     -304,     -492, ... 
              -168,      126,      400,      304, ... 
                17,      -84,      -82,      -12, ... 
               -11,      -37,      -27,        4, ... 
                26,       16,        2,        1, ... 
                 5 ]'/1024;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c.ok"; fail; fi

cat > test_kk.ok << 'EOF'
kk_min = [        0,        0,        0,        0, ... 
                  0,        0,        0,        0, ... 
                  0,        0,        0,        0, ... 
                  0,        0,        0,        0, ... 
                  0,        0,        0 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kk.ok"; fail; fi

cat > test_ck.ok << 'EOF'
ck_min = [       -8,        0,     -246,        0, ... 
                 42,        0,      128,        0, ... 
                -25,        0,       -3,        0, ... 
                 -5,        0,        1,        0, ... 
                  0,        0,        1 ]'/1024;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ck.ok"; fail; fi

cat > test_cost.tab.ok << 'EOF'
Exact & 0.0129 & & \\
10-bit 3-signed-digit&0.0249 & 97 & 57 \\
10-bit 3-signed-digit(branch-and-bound)&0.0181 & 93 & 53 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.tab.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_schurOneMlatticePipelined_bandpass_10_nbits_test"

diff -Bb test_k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_k.ok"; fail; fi

diff -Bb test_c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_c.ok"; fail; fi

diff -Bb test_kk.ok $nstr"_kk_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_kk.ok"; fail; fi

diff -Bb test_ck.ok $nstr"_ck_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_ck.ok"; fail; fi

diff -Bb test_cost.tab.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_cost.tab.ok"; fail; fi

#
# this much worked
#
pass
