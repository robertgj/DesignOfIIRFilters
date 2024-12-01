#!/bin/sh

prog=schurOneMPAlattice_socp_mmse_test.m
depends="test/schurOneMPAlattice_socp_mmse_test.m test_common.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m schurOneMPAlatticeEsq.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
tf2schurOneMlattice.m schurOneMscale.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.m qzsolve.oct"

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
cat > test_D1_coef.m << 'EOF'
D1 = [   1.0000000000,   0.7327449186,  -0.2702108338,  -0.3119100099, ... 
        -0.2311495522,  -0.0189065699,   0.0514412675,  -0.0718739084, ... 
         0.2405589263,   0.0710262997,  -0.1467474243,   0.0207586124 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D1_coef.m"; fail; fi

cat > test_D2_coef.m << 'EOF'
D2 = [   1.0000000000,   0.0681543802,  -0.4784705863,   0.2704312346, ... 
         0.1600434566,   0.1298776744,  -0.0733203772,  -0.2210505279, ... 
         0.2694094084,  -0.0996058461,  -0.1189644751,   0.1506204908, ... 
        -0.0729681355 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_D1_coef.m schurOneMPAlattice_socp_mmse_test_D1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D1_coef.m"; fail; fi

diff -Bb test_D2_coef.m schurOneMPAlattice_socp_mmse_test_D2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2_coef.m"; fail; fi

#
# this much worked
#
pass

