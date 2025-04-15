#!/bin/sh

prog=branch_bound_schurOneMlattice_bandpass_R2_10_nbits_test.m

depends="test/branch_bound_schurOneMlattice_bandpass_R2_10_nbits_test.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_N2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_R2_test_D2_coef.m \
schurOneMlattice_bandpass_R2_10_nbits_common.m test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_sqp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlatticeFilter.m \
tf2schurOneMlattice.m \
local_max.m x2tf.m tf2pa.m print_polynomial.m x2nextra.m sqp_bfgs.m \
armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
SDadders.m Abcd2ng.m KW.m delayz.m \
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
k_min = [        0,      336,        0,      255, ... 
                 0,      176,        0,      216, ... 
                 0,      152,        0,      129, ... 
                 0,       78,        0,       54, ... 
                 0,       19,        0,        7 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c.ok << 'EOF'
c_min = [       73,      -14,     -312,     -492, ... 
              -164,      126,      416,      312, ... 
                18,      -88,      -81,      -13, ... 
               -11,      -37,      -27,        5, ... 
                26,       17,        3,        1, ... 
                 5 ]'/1024;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test_cost.tab.ok << 'EOF'
Exact & 7.9778e-03 & & \\
10-bit 3-signed-digit&1.3944e-02 & 79 & 48 \\
10-bit 3-signed-digit(branch-and-bound)&9.8387e-03 & 81 & 50 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.tab.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_schurOneMlattice_bandpass_R2_10_nbits_test"

diff -Bb test.k.ok $nstr"_k_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test_cost.tab.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_cost.tab.ok"; fail; fi

#
# this much worked
#
pass
