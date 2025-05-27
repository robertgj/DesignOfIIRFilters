#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_differentiator_test.m

depends="test/schurOneMlattice_socp_slb_lowpass_differentiator_test.m \
test_common.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
schurOneMlatticeFilter.m \
local_max.m tf2pa.m x2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m print_pole_zero.m p2n60.m crossWelch.m \
qroots.oct schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
k2 = [   0.3245174840,   0.5781526596,  -0.3974727312,   0.3520518111, ... 
        -0.2991718343,   0.2343584869,  -0.1633806872,   0.0985543464, ... 
        -0.0489077827,   0.0186202839,  -0.0061187713 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  -1.0000000000,   1.0000000000,   1.0000000000,   1.0000000000, ... 
               1.0000000000,  -1.0000000000,  -1.0000000000,  -1.0000000000, ... 
               1.0000000000,  -1.0000000000,   1.0000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.1613046180,  -0.2321622076,  -0.6602583304,   0.0329292928, ... 
         0.0689297307,  -0.0476499369,   0.0160058942,   0.0023352353, ... 
        -0.0095424050,   0.0070946652,  -0.0026431334,  -0.0007082368 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_lowpass_differentiator_test";

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.ok"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.epsilon2.ok"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.ok"; fail; fi

#
# this much worked
#
pass
