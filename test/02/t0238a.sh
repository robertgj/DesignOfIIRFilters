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
complex_zhong_inverse.oct schurOneMlattice2H.oct schurOneMlattice2Abcd.oct \
SeDuMi_1_3/"

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
cat > test.k2.ok << 'EOF'
k2 = [   0.0000000000,  -0.9490911040,   0.0000000000,   0.4305027966, ... 
         0.0000000000,   0.0057077792,   0.0000000000,  -0.0053543674, ... 
         0.0000000000,   0.0074026750,   0.0000000000,   0.0003039022 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi
cat > test.p2.ok << 'EOF'
p2 = [   3.8315051298,   3.8315051298,   0.6192274231,   0.6192274231, ... 
         0.9814060681,   0.9814060681,   0.9870237954,   0.9870237954, ... 
         0.9923229081,   0.9923229081,   0.9996961439,   0.9996961439 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.0267182526,   0.0307694190,   0.1650278580,   0.2143908152, ... 
         0.1624187514,   0.2522917327,   0.6828293765,  -0.6069988051, ... 
        -0.1747842795,  -0.0875837784,  -0.0479815884,  -0.0267987952, ... 
        -0.0233760342 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 
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

