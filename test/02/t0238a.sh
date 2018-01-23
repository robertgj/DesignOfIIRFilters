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
k2 = [   0.0000000000,  -0.9484846068,   0.0000000000,   0.4288911418, ... 
         0.0000000000,   0.0021184559,   0.0000000000,  -0.0051276650, ... 
         0.0000000000,   0.0077384215,   0.0000000000,   0.0004673067 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   3.8285040923,   3.8285040923,   0.6225140178,   0.6225140178, ... 
         0.9846667186,   0.9846667186,   0.9867549058,   0.9867549058, ... 
         0.9918276936,   0.9918276936,   0.9995328024,   0.9995328024 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.0269519682,   0.0309637105,   0.1628995841,   0.2125727893, ... 
         0.1618121279,   0.2513135348,   0.6823579992,  -0.6078350231, ... 
        -0.1759384772,  -0.0886616629,  -0.0491950594,  -0.0274190942, ... 
        -0.0237891341 ];
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

