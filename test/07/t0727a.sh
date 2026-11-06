#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_hilbert_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_hilbert_test.m \
../tarczynski_bandpass_hilbert_test_N0_coef.m \
../tarczynski_bandpass_hilbert_test_D0_coef.m \
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
k2 = [  -0.9219357723,   0.9789925680,  -0.3720312237,   0.7261745035, ... 
        -0.7485204548,   0.8208295677,  -0.6247165492,   0.7561024913, ... 
        -0.6622047441,   0.7053749530,  -0.6052805250,   0.4407976673, ... 
        -0.1205944015,  -0.1171564374,   0.1198797388,  -0.0516964073 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  1,  1,  1, -1, ... 
             -1, -1,  1,  1, ... 
              1,  1,  1,  1, ... 
              1,  1, -1,  1 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   0.3217607375,   1.5965276700,   0.1644905115,   0.2431385505, ... 
         0.6104628362,   0.2315129051,   0.7380345316,   1.5356271354, ... 
         0.5722878561,   1.2694921395,   0.5276608934,   1.0641089591, ... 
         0.6629321610,   0.7483395522,   0.8418094924,   0.9495733178 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.4625251709,  -0.0356604919,  -0.3077972064,  -0.0208100486, ... 
         0.5618203857,   0.9647902305,  -0.3517503111,  -0.1782768251, ... 
         0.0166675512,   0.0666687285,   0.0082185648,   0.0027481537, ... 
         0.0373709716,   0.0302932450,  -0.0031903230,  -0.0050300970, ... 
        -0.0009592102 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_bandpass_hilbert_test"

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
