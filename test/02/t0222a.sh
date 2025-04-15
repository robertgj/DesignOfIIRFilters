#!/bin/sh

prog=schurOneMlattice_sqp_slb_hilbert_R2_test.m

depends="test/schurOneMlattice_sqp_slb_hilbert_R2_test.m test_common.m \
../tarczynski_hilbert_R2_test_N0_coef.m \
../tarczynski_hilbert_R2_test_D0_coef.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlatticedAsqdw.m \
schurOneMlattice_sqp_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_sqp_slb_hilbert_plot.m \
schurOneMlattice2Abcd.oct schurOneMscale.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m x2tf.m tf2pa.m print_polynomial.m sqp_bfgs.m  \
armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m H2dAsqdw.m qroots.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct Abcd2tf.oct"

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
cat > test.k2.ok << 'EOF'
k2 = [   0.0000000000,  -0.8105864394,   0.0000000000,   0.2655181645, ... 
         0.0000000000,  -0.0336215102,   0.0000000000,   0.0012379481, ... 
         0.0000000000,  -0.0003065055,   0.0000000000,   0.0001110418 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   2.2737060699,   2.2737060699,   0.7354111726,   0.7354111726, ... 
         0.9653257368,   0.9653257368,   0.9983458736,   0.9983458736, ... 
         0.9995825399,   0.9995825399,   0.9998889644,   0.9998889644 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0437647324,  -0.0526095103,  -0.1506187275,  -0.1846670626, ... 
        -0.1806322200,  -0.2725453506,  -0.6912602247,   0.5823145464, ... 
         0.1563236592,   0.0717407970,   0.0366475456,   0.0185442080, ... 
         0.0085434874 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_sqp_slb_hilbert_R2_test"

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k2.ok"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.epsilon2.ok"; fail; fi

diff -Bb test.p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.p2.ok"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c2.ok"; fail; fi

#
# this much worked
#
pass

