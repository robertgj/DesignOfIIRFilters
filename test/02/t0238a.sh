#!/bin/sh

prog=schurOneMlattice_socp_slb_hilbert_test.m

depends="test/schurOneMlattice_socp_slb_hilbert_test.m test_common.m \
../tarczynski_hilbert_test_D0_coef.m \
../tarczynski_hilbert_test_N0_coef.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_sqp_slb_hilbert_plot.m \
schurOneMscale.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m print_polynomial.m Abcd2tf.m \
H2Asq.m H2T.m H2P.m spectralfactor.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct schurOneMlattice2Abcd.oct"

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
k2 = [   0.0000000000,  -0.8882007406,   0.0000000000,   0.4143397981, ... 
         0.0000000000,  -0.0241507619,   0.0000000000,   0.0020171512, ... 
        -0.0000000000,   0.0034043153,  -0.0000000000,  -0.0006666491 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   2.5657596404,   2.5657596404,   0.6243258985,   0.6243258985, ... 
         0.9702091710,   0.9702091710,   0.9939303635,   0.9939303635, ... 
         0.9959372975,   0.9959372975,   0.9993335730,   0.9993335730 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.0438596238,   0.0535669622,   0.2283008071,   0.2931953911, ... 
         0.2704844897,   0.7112483643,  -0.5853417523,  -0.1570955999, ... 
        -0.0727207029,  -0.0376249531,  -0.0209968361,  -0.0111216994, ... 
        -0.0053934323 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k2.ok schurOneMlattice_socp_slb_hilbert_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k2.ok"; fail; fi

diff -Bb test.epsilon2.ok schurOneMlattice_socp_slb_hilbert_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.epsilon2.ok"; fail; fi

diff -Bb test.p2.ok schurOneMlattice_socp_slb_hilbert_test_p2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.p2.ok"; fail; fi

diff -Bb test.c2.ok schurOneMlattice_socp_slb_hilbert_test_c2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c2.ok"; fail; fi

#
# this much worked
#
pass

