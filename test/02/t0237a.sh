#!/bin/sh

prog=schurOneMlattice_pop_mmse_test.m

depends="test/schurOneMlattice_pop_mmse_test.m \
../schurOneMlattice_socp_slb_bandpass_test_N3_coef.m \
../schurOneMlattice_socp_slb_bandpass_test_D3_coef.m \
schurOneMlattice_pop_mmse.m \
schurOneMlattice_bandpass_10_nbits_common.m test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
schurOneMlattice2tf.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlatticeFilter.m \
tf2schurOneMlattice.m \
local_max.m print_polynomial.m x2nextra.m sqp_bfgs.m \
armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m \
SDadders.m schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
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
k1 = [     -452,      498,     -352,      407, ... 
           -304,      422,     -337,      390, ... 
           -302,      266,      -94,       23, ... 
             12,       10,       -1,        6, ... 
            -13,       15,       -9,        2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.c.ok << 'EOF'
c1 = [      -98,      -64,     -452,     -321, ... 
             24,      510,      752,     -352, ... 
            -96,       -8,        8,      -12, ... 
             -9,        9,       15,        4, ... 
             -1,        1,        4,        2, ... 
             -4 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_pop_mmse_test"

diff -Bb test.k.ok $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

diff -Bb test.c.ok $nstr"_c1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi

#
# this much worked
#
pass
