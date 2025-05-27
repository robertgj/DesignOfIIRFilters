#!/bin/sh

prog=socp_relaxation_schurOneMlattice_lowpass_R2_15_nbits_test.m
depends="test/socp_relaxation_schurOneMlattice_lowpass_R2_15_nbits_test.m \
../schurOneMlattice_socp_slb_lowpass_R2_test_k2_coef.m \
../schurOneMlattice_socp_slb_lowpass_R2_test_epsilon2_coef.m \
../schurOneMlattice_socp_slb_lowpass_R2_test_c2_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_socp_slb_lowpass_plot.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlattice_allocsd_Ito.m \
local_max.m H2Asq.m print_polynomial.m tf2Abcd.m delayz.m \
x2nextra.m flt2SD.m SDadders.m bin2SDul.m schurOneMlatticeFilter.m \
qroots.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct Abcd2tf.oct qroots.oct \
bin2SD.oct bin2SPT.oct"

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
k_min = [        0,     4865,        0,    15817, ... 
                 0,     -160,        0,    10311, ... 
                 0,    -4474,        0,     3740, ... 
                 0,    -1688,        0,      476 ]'/16384;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [      740,     1473,      976,      112, ... 
             -4720,    -9233,    -8207,    -1568, ... 
              3680,     6894,     6236,     5680, ... 
              3232,     1912,      784,      249, ... 
                36 ]'/16384;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 1.1123e-04 & & \\
15-bit 4-signed-digit & 1.7437e-04 & 92 & 67 \\
15-bit 4-signed-digit(Lim)& 1.2989e-04 & 95 & 70 \\
15-bit 4-signed-digit(SOCP-relax) & 1.2635e-04 & 95 & 70 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_schurOneMlattice_lowpass_R2_15_nbits_test"

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
