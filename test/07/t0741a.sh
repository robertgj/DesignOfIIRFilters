#!/bin/sh

prog=socp_relaxation_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test.m
depends="\
test/socp_relaxation_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test.m \
../schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A1k2_coef.m \
../schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A2k2_coef.m \
test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMscale.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
schurOneMPAlattice_allocsd_Lim.m \
schurOneMPAlattice_allocsd_Ito.m \
local_max.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
flt2SD.m x2nextra.m bin2SDul.m SDadders.m delayz.m \
qroots.oct bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct"

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
cat > test_A1k_min.ok << 'EOF'
A1k_min = [     1192,     1538,     -432,     -344, ... 
                 330,      -88,      -20,       16 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_min.ok"; fail; fi

cat > test_A2k_min.ok << 'EOF'
A2k_min = [     -509,      488,      -54,     -184, ... 
                 168,      -70,       14,        0 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 6.7387e-02 & & \\
12-bit 3-signed-digit(Lim)& 6.7357e-02 & 45 & 30 \\
12-bit 3-signed-digit(SOCP-relax) & 6.7400e-02 & 44 & 29 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. .
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test"

diff -Bb test_A1k_min.ok $nstr"_A1k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_min.ok"; fail; fi

diff -Bb test_A2k_min.ok $nstr"_A2k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

