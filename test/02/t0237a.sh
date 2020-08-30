#!/bin/sh

prog=schurOneMlattice_pop_socp_mmse_test.m

depends="schurOneMlattice_pop_socp_mmse_test.m \
schurOneMlattice_pop_socp_mmse.m \
schurOneMlattice_bandpass_10_nbits_common.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlatticeFilter.m \
tf2schurOneMlattice.m \
local_max.m print_polynomial.m Abcd2tf.m x2nextra.m sqp_bfgs.m \
armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
SDadders.m schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct"

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
k1 = [        0,      336,        0,      256, ... 
              0,      176,        0,      216, ... 
              0,      152,        0,      128, ... 
              0,       77,        0,       52, ... 
              0,       18,        0,        7 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.c.ok << 'EOF'
c1 = [       36,       -8,     -156,     -248, ... 
            -82,       62,      200,      152, ... 
              8,      -42,      -40,       -8, ... 
             -5,      -16,      -13,        3, ... 
             14,        8,        2,        0, ... 
              2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k.ok schurOneMlattice_pop_socp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok schurOneMlattice_pop_socp_mmse_test_c1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

#
# this much worked
#
pass
