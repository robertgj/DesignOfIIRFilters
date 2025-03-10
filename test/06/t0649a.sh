#!/bin/sh

prog=schurOneMlattice_piqp_slb_hilbert_test.m

depends="test/schurOneMlattice_piqp_slb_hilbert_test.m test_common.m \
../tarczynski_hilbert_test_D0_coef.m \
../tarczynski_hilbert_test_N0_coef.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_piqp_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_sqp_slb_hilbert_plot.m \
schurOneMlattice2tf.m \
schurOneMscale.m tf2schurOneMlattice.m qroots.oct \
local_max.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct Abcd2tf.oct \
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
cat > test_k2.ok << 'EOF'
k2 = [   0.0000000000,  -0.8280549980,   0.0000000000,   0.2966374524, ... 
         0.0000000000,  -0.0353414744,   0.0000000000,   0.0013613041, ... 
         0.0000000000,  -0.0003726232,   0.0000000000,   0.0002276574 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2.ok"; fail; fi

cat > test_epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2.ok"; fail; fi

cat > test_p2.ok << 'EOF'
p2 = [   2.3135201225,   2.3135201225,   0.7095343587,   0.7095343587, ... 
         0.9633699421,   0.9633699421,   0.9980403370,   0.9980403370, ... 
         0.9993998995,   0.9993998995,   0.9997723685,   0.9997723685 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_p2.ok"; fail; fi

cat > test_c2.ok << 'EOF'
c2 = [  -0.0433446441,  -0.0519116163,  -0.1572889747,  -0.1919845552, ... 
        -0.1801680393,  -0.2719319388,  -0.6900916403,   0.5839611042, ... 
         0.1577638671,   0.0729907478,   0.0376425637,   0.0192698769, ... 
         0.0090334626 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k2.ok schurOneMlattice_piqp_slb_hilbert_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2.ok"; fail; fi

diff -Bb test_epsilon2.ok schurOneMlattice_piqp_slb_hilbert_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2.ok"; fail; fi

diff -Bb test_p2.ok schurOneMlattice_piqp_slb_hilbert_test_p2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_p2.ok"; fail; fi

diff -Bb test_c2.ok schurOneMlattice_piqp_slb_hilbert_test_c2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c2.ok"; fail; fi

#
# this much worked
#
pass
