#!/bin/sh

prog=sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test.m

depends="test/sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test.m \
../schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m \
schurOneMlattice_bandpass_10_nbits_common.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
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
schurOneMlatticeFilter.m \
tf2schurOneMlattice.m \
local_max.m print_polynomial.m x2nextra.m sqp_bfgs.m armijo_kim.m \
updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m SDadders.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct \
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
cat > test.k.ok << 'EOF'
k_min = [        0,      329,        0,      256, ... 
                 0,      176,        0,      215, ... 
                 0,      148,        0,      128, ... 
                 0,       76,        0,       52, ... 
                 0,       18,        0,        8 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi
cat > test.c.ok << 'EOF'
c_min = [       38,       -8,     -156,     -248, ... 
               -81,       64,      200,      152, ... 
                 8,      -43,      -40,       -8, ... 
                -4,      -17,      -12,        2, ... 
                12,        8,        1,        0, ... 
                 2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi
cat > test.cost.ok << 'EOF'
Exact & 0.0155 & & \\
10-bit 3-signed-digit&0.0361 & 73 & 42 \\
10-bit 3-signed-digit(Ito)&0.0654 & 65 & 34 \\
10-bit 3-signed-digit(SQP-relax) & 0.0192 & 63 & 33 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test"

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
