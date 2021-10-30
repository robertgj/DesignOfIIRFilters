#!/bin/sh

prog=schurOneMlattice_socp_slb_hilbert_test.m

depends="schurOneMlattice_socp_slb_hilbert_test.m \
../tarczynski_hilbert_test_D0_coef.m \
../tarczynski_hilbert_test_N0_coef.m \
test_common.m \
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
k2 = [   0.0000000000,  -0.8914517737,   0.0000000000,   0.4195579213, ... 
         0.0000000000,  -0.0214985516,   0.0000000000,   0.0022611396, ... 
        -0.0000000000,   0.0030754862,  -0.0000000000,  -0.0007030281 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   2.5967373272,   2.5967373272,   0.6220735704,   0.6220735704, ... 
         0.9728342776,   0.9728342776,   0.9939785345,   0.9939785345, ... 
         0.9962286055,   0.9962286055,   0.9992972188,   0.9992972188 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.0430558780,   0.0528901479,   0.2311740085,   0.2955078991, ... 
         0.2696090622,   0.7092943241,  -0.5860198705,  -0.1574640465, ... 
        -0.0726540425,  -0.0377281152,  -0.0212543642,  -0.0118755876, ... 
        -0.0067528889 ];
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

