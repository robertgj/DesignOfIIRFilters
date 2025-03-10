#!/bin/sh

prog=branch_bound_schurOneMlatticePipelined_lowpass_16_nbits_test.m

depends="test/branch_bound_schurOneMlatticePipelined_lowpass_16_nbits_test.m \
test_common.m schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelinedAsq.m schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m schurOneMlatticePipelinedEsq.m \
schurOneMscale.m tf2schurOneMlattice.m local_max.m x2tf.m tf2pa.m \
print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
x2nextra.m SDadders.m Abcd2ng.m KW.m qroots.oct \
Abcd2H.oct schurdecomp.oct schurexpand.oct bin2SPT.oct bin2SD.oct"

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
k_min = [   -20288,    32016,   -26112,    28992, ... 
            -27632,    26688,   -23424,    14912, ... 
             -4165 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k.ok"; fail; fi

cat > test_c.ok << 'EOF'
c_min = [    -8138,    -3296,     8440,    20996, ... 
             84480,    15552,     2132,     1720, ... 
               281,       42 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c.ok"; fail; fi

cat > test_kk.ok << 'EOF'
kk_min = [   -19840,   -25472,   -23040,   -24446, ... 
             -22496,   -19072,   -10624,    -1900 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kk.ok"; fail; fi

cat > test_ck.ok << 'EOF'
ck_min = [    -3232,        0,    18576,        0, ... 
              12672,        0,      782,        0 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ck.ok"; fail; fi

cat > test_cost.tab.ok << 'EOF'
Exact & 0.00027853 & & \\
16-bit 4-signed-digit&0.00161778 & 123 & 92 \\
16-bit 4-signed-digit(branch-and-bound)&0.00063430 & 122 & 91 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.tab.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_schurOneMlatticePipelined_lowpass_16_nbits_test"

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
