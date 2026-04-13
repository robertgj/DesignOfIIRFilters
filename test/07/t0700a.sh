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
k2 = [   0.0000000000,   0.7605426558,   0.0000000000,   0.4795868914, ... 
         0.0000000000,   0.2851245250,   0.0000000000,   0.5115864964, ... 
         0.0000000000,   0.3326496835,   0.0000000000,   0.4379805319, ... 
         0.0000000000,   0.2635307334,   0.0000000000,   0.2594596551, ... 
         0.0000000000,   0.1015752522,   0.0000000000,   0.0634361197 ]';
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
p2 = [   1.1849813121,   1.1849813121,   0.4370209996,   0.4370209996, ... 
         0.7368828176,   0.7368828176,   0.9879974795,   0.9879974795, ... 
         0.5616078457,   0.5616078457,   0.7936229736,   0.7936229736, ... 
         0.4961504708,   0.4961504708,   0.6498737554,   0.6498737554, ... 
         0.8475137770,   0.8475137770,   0.9384540195,   0.9384540195 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0447018889,   0.0933375779,   0.4943167537,   0.2542777211, ... 
        -0.1851448997,  -0.4349373219,  -0.2396988836,  -0.0219102765, ... 
         0.1923410116,   0.1584595663,   0.0403313241,   0.0090019193, ... 
         0.0659235102,   0.0426861603,   0.0000904411,  -0.0349026287, ... 
        -0.0118987519,  -0.0069083246,  -0.0069387967,  -0.0114569673, ... 
        -0.0045580028 ]';
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
