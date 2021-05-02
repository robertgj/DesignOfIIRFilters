#!/bin/sh

prog=schurOneMlattice_socp_slb_hilbert_test.m

depends="schurOneMlattice_socp_slb_hilbert_test.m test_common.m \
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
k2 = [   0.0000000000,  -0.9470999826,   0.0000000000,   0.4283144122, ... 
         0.0000000000,  -0.0000461091,   0.0000000000,  -0.0052649281, ... 
         0.0000000000,   0.0065371213,   0.0000000000,   0.0001943979 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0,  1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   3.7923014702,   3.7923014702,   0.6250814852,   0.6250814852, ... 
         0.9880295249,   0.9880295249,   0.9880750831,   0.9880750831, ... 
         0.9932909943,   0.9932909943,   0.9998056210,   0.9998056210 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.0270884777,   0.0313240395,   0.1622165740,   0.2109875644, ... 
         0.1619621326,   0.2506690186,   0.6819425639,  -0.6061154241, ... 
        -0.1745750128,  -0.0879629077,  -0.0478475797,  -0.0265033333, ... 
        -0.0229701434 ];
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

