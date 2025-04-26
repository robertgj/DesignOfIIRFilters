#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_hilbert_R2_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_hilbert_R2_test.m \
../tarczynski_bandpass_hilbert_R2_test_N0_coef.m \
../tarczynski_bandpass_hilbert_R2_test_D0_coef.m \
test_common.m \
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
local_max.m tf2pa.m x2tf.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
qroots.oct delayz.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
k2 = [   0.0000000000,   0.7001011163,   0.0000000000,   0.4261124087, ... 
         0.0000000000,   0.2886396233,   0.0000000000,   0.5012523996, ... 
         0.0000000000,   0.3358172035,   0.0000000000,   0.4272308707, ... 
         0.0000000000,   0.2615024930,   0.0000000000,   0.2478782477, ... 
         0.0000000000,   0.0973834149,   0.0000000000,   0.0606765500 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1, ... 
              0, -1,  0, -1 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   1.0986430837,   1.0986430837,   0.4614309005,   0.4614309005, ... 
         0.7273947071,   0.7273947071,   0.9790188225,   0.9790188225, ... 
         0.5642929102,   0.5642929102,   0.8002658763,   0.8002658763, ... 
         0.5069638411,   0.5069638411,   0.6625925133,   0.6625925133, ... 
         0.8534705837,   0.8534705837,   0.9410573663,   0.9410573663 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0420598224,   0.0981910014,   0.4723663448,   0.2649154812, ... 
        -0.1745141683,  -0.4392432771,  -0.2488290179,  -0.0237240948, ... 
         0.1979372060,   0.1601911857,   0.0323032308,   0.0040201827, ... 
         0.0668033783,   0.0513460808,   0.0013306865,  -0.0357162951, ... 
        -0.0119214202,  -0.0032260123,  -0.0052285174,  -0.0139349362, ... 
        -0.0067181691 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_bandpass_hilbert_R2_test"

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.coef"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.epsilon2.coef"; fail; fi

diff -Bb test.p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.p2.coef"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.coef"; fail; fi

#
# this much worked
#
pass
