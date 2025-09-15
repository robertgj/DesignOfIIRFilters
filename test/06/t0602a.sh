#!/bin/sh

prog=branch_bound_schurOneMlatticePipelined_bandpass_10_nbits_test.m

depends="test/branch_bound_schurOneMlatticePipelined_bandpass_10_nbits_test.m \
../schurOneMlattice_socp_slb_bandpass_test_N3_coef.m \
../schurOneMlattice_socp_slb_bandpass_test_D3_coef.m \
test_common.m schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelinedAsq.m schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m schurOneMlatticePipelinedEsq.m \
schurOneMscale.m tf2schurOneMlatticePipelined.m local_max.m x2tf.m tf2pa.m \
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
k_min = [     -450,      497,     -352,      416, ... 
              -296,      416,     -336,      392, ... 
              -296,      265,      -94,       23, ... 
                13,       11,       -1,        7, ... 
               -14,       15,       -9,        2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k.ok"; fail; fi

cat > test_c.ok << 'EOF'
c_min = [      -98,      -65,     -452,     -320, ... 
                22,      510,      736,     -352, ... 
               -94,       -7,        8,      -13, ... 
               -10,       10,       15,        5, ... 
                -2,        2,        4,        3, ... 
                -4 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c.ok"; fail; fi

cat > test_kk.ok << 'EOF'
kk_min = [     -432,     -336,     -280,     -242, ... 
               -249,     -276,     -257,     -232, ... 
               -158,      -50,       -5,        0, ... 
                  1,       -1,       -1,       -1, ... 
                 -1,       -1,       -1 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kk.ok"; fail; fi

cat > test_ck.ok << 'EOF'
ck_min = [      -62,        0,     -255,        0, ... 
                416,        0,     -260,        0, ... 
                 -5,        0,       -1,        0, ... 
                  0,        0,        0,        0, ... 
                  1,        0,        0 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ck.ok"; fail; fi

cat > test_cost.tab.ok << 'EOF'
Exact & 0.0226 & & \\
10-bit 3-signed-digit&0.4562 & 136 & 77 \\
10-bit 3-signed-digit(branch-and-bound)&0.0496 & 147 & 81 \\
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
