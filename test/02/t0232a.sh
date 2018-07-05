#!/bin/sh

prog=branch_bound_schurOneMlattice_bandpass_10_nbits_test.m

depends="branch_bound_schurOneMlattice_bandpass_10_nbits_test.m \
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
local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m x2nextra.m sqp_bfgs.m \
armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
SDadders.m schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct \
qroots.m qzsolve.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
k_min = [        0,      351,        0,      264, ... 
                 0,      188,        0,      216, ... 
                 0,      156,        0,      128, ... 
                 0,       78,        0,       49, ... 
                 0,       17,        0,        6 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.c.ok << 'EOF'
c_min = [       72,       -2,     -272,     -496, ... 
              -184,       96,      388,      320, ... 
                30,      -80,      -84,      -16, ... 
                -4,      -32,      -24,        4, ... 
                24,       16,        1,        0, ... 
                 4 ]'/1024;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi
cat > test_cost.tab.ok << 'EOF'
Exact & 0.0145 & & \\
10-bit 3-signed-digit(Ito)&0.0385 & 64 & 34 \\
10-bit 3-signed-digit(branch-and-bound)&0.0210 & 61 & 31 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.tab.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k.ok branch_bound_schurOneMlattice_bandpass_10_nbits_test_k_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok branch_bound_schurOneMlattice_bandpass_10_nbits_test_c_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

diff -Bb test_cost.tab.ok \
     branch_bound_schurOneMlattice_bandpass_10_nbits_test_cost.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_cost.tab.ok"; fail; fi

#
# this much worked
#
pass
