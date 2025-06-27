#!/bin/sh

prog=branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m

depends="test/branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_p2_coef.m \
../schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef.m \
test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m schurOneMlatticeEsq.m schurOneMscale.m \
tf2schurOneMlattice.m schurOneMlattice2tf.m schurOneMlattice_allocsd_Ito.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m flt2SD.m bin2SDul.m x2nextra.m SDadders.m \
local_max.m tf2pa.m print_polynomial.m Abcd2ng.m KW.m delayz.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct \
qroots.oct Abcd2tf.oct"

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
k_min = [        0,     2864,        0,     1760, ... 
                 0,     1184,        0,     2048, ... 
                 0,     1376,        0,     1752, ... 
                 0,     1072,        0,     1016, ... 
                 0,      400,        0,      249 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [     -176,      400,     1928,     1088, ... 
              -715,    -1792,    -1019,      -96, ... 
               812,      656,      132,       16, ... 
               272,      216,        4,     -146, ... 
               -49,      -13,      -21,      -57, ... 
               -28 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 2.5803e-03 & -33.99 & & \\
13-bit 3-signed-digit&3.4972e-03 & -31.39 & 88 & 57 \\
13-bit 3-signed-digit(Ito)&2.4835e-03 & -33.23 & 84 & 53 \\
13-bit 3-signed-digit(b-and-b)& 1.9652e-03 & -33.60& 89 & 58\\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test"

diff -Bb test.k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
