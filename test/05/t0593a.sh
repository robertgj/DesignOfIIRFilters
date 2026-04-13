#!/bin/sh

prog=branch_bound_schurNSPAlattice_lowpass_12_nbits_test.m
depends="test/branch_bound_schurNSPAlattice_lowpass_12_nbits_test.m \
test_common.m \
../schurNSPAlattice_socp_slb_lowpass_test_A1s20_coef.m \
../schurNSPAlattice_socp_slb_lowpass_test_A1s00_coef.m \
../schurNSPAlattice_socp_slb_lowpass_test_A2s20_coef.m \
../schurNSPAlattice_socp_slb_lowpass_test_A2s00_coef.m \
schurNSPAlatticeAsq.m schurNSPAlatticeT.m \
schurNSPAlatticeP.m schurNSPAlatticeEsq.m \
schurNSPAlattice_slb.m schurNSPAlattice_socp_mmse.m \
schurNSPAlattice_slb_set_empty_constraints.m \
schurNSPAlattice_slb_constraints_are_empty.m \
schurNSPAlattice_slb_update_constraints.m \
schurNSPAlattice_slb_exchange_constraints.m \
schurNSPAlattice_slb_show_constraints.m \
schurNSPAlattice2tf.m schurNSAPlattice2tf.m schurNSAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m flt2SD.m bin2SDul.m x2nextra.m \
SDadders.m H2Asq.m H2T.m H2P.m tf2schurNSlattice.m \
schurNSscale.oct bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
Abcd2H.oct complex_zhong_inverse.oct schurNSlattice2Abcd.oct Abcd2tf.oct \
qroots.oct"

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
cat > test_A1s20_min_coef.m << 'EOF'
A1s20_min = [     1600,     -146,     -560,     -208, ... 
                  -216,      472,     -259,       47, ... 
                   368,     -336,       94 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_min_coef.m"; fail; fi

cat > test_A1s00_min_coef.m << 'EOF'
A1s00_min = [     1272,     2038,     1976,     2036, ... 
                  2038,     2000,     2032,     2044, ... 
                  2014,     2024,     2043 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_min_coef.m"; fail; fi

cat > test_A2s20_min_coef.m << 'EOF'
A2s20_min = [      752,     -608,      456,      432, ... 
                   -42,       94,     -416,      376, ... 
                    17,     -380,      296,     -120 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_min_coef.m"; fail; fi

cat > test_A2s00_min_coef.m << 'EOF'
A2s00_min = [     1904,     1952,     1992,     2008, ... 
                  2045,     2044,     2014,     2014, ... 
                  2043,     2014,     2028,     2044 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_min_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=branch_bound_schurNSPAlattice_lowpass_12_nbits_test

diff -Bb test_A1s20_min_coef.m $nstr"_A1s20_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s20_min_coef.m"; fail; fi

diff -Bb test_A1s00_min_coef.m $nstr"_A1s00_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s00_min_coef.m"; fail; fi

diff -Bb test_A2s20_min_coef.m $nstr"_A2s20_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_min_coef.m"; fail; fi

diff -Bb test_A2s00_min_coef.m $nstr"_A2s00_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_min_coef.m"; fail; fi

#
# this much worked
#
pass

