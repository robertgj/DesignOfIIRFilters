#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test.m

depends="test/schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test.m \
test_common.m \
../iir_sqp_slb_lowpass_differentiator_alternate_test_D1_coef.m \
../iir_sqp_slb_lowpass_differentiator_alternate_test_N1_coef.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_socp_slb_lowpass_plot.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
print_polynomial.m print_pole_zero.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct qroots.m qzsolve.oct"

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
k2 = [  -0.2812722202,   0.9749403828,  -0.6337173090,   0.6916463537, ... 
        -0.7006149013,   0.6768687830,  -0.6151392256,   0.4882615035, ... 
        -0.2899281212,   0.1044693405,  -0.0179860570 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  1,  1,  1, -1, ... 
             -1, -1, -1, -1, ... 
              1, -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   1.1084749804,   1.4800090958,   0.1667149726,   0.3520909502, ... 
         0.8246793251,   0.3460168172,   0.7882378564,   0.3847725939, ... 
         0.6561750466,   0.8844052448,   0.9821728214 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0060644902,  -0.0147766987,   1.4111830129,   0.7359763899, ... 
         0.0202599449,  -0.1608163928,   0.0095506693,   0.0372475745, ... 
        -0.0058292666,  -0.0058904477,   0.0011302632,   0.0018945742 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test";

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.ok"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.epsilon2.ok"; fail; fi

diff -Bb test.p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.p2.ok"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.ok"; fail; fi

#
# this much worked
#
pass
