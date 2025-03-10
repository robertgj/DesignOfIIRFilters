#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_test.m \
../tarczynski_bandpass_R1_test_N0_coef.m \
../tarczynski_bandpass_R1_test_D0_coef.m \
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
qroots.oct \
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
cat > test.k3.ok << 'EOF'
k3 = [  -0.9186572944,   0.9546729409,  -0.3173518298,   0.8220540368, ... 
        -0.7161646357,   0.7904525196,  -0.6031947259,   0.7513699838, ... 
        -0.5631460208,   0.5579567925,  -0.0834562855,  -0.1354671039, ... 
         0.2292286071,   0.0613762799,  -0.1705163795,   0.1493581739, ... 
         0.0040517357,  -0.0638974270,   0.0496452529,  -0.0165834165 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  1,  1,  1, -1, ... 
             -1, -1, -1,  1, ... 
              1, -1,  1,  1, ... 
             -1, -1, -1, -1, ... 
             -1,  1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   0.2121849235,   1.0305140567,   0.1569262659,   0.2179957692, ... 
         0.6975649023,   0.2836863239,   0.8292368289,   0.4125476926, ... 
         0.1554397147,   0.2940313359,   0.5519998515,   0.6001614083, ... 
         0.6878038186,   0.8685965865,   0.9236491705,   0.7775390402, ... 
         0.9038087301,   0.9074781730,   0.9674406860,   1.0167232305 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [  -0.1665417515,  -0.1453525355,  -0.3979571670,  -0.9964834142, ... 
         0.0455884052,   1.5192038405,   0.2206722499,  -0.4285873508, ... 
        -0.9293598920,  -0.0263443277,   0.0061679792,  -0.0473080260, ... 
        -0.0280703066,   0.0175161668,   0.0247784534,   0.0070056652, ... 
         0.0000512979,   0.0057704044,   0.0137345571,  -0.0017392142, ... 
        -0.0025743627 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k3.ok schurOneMlattice_socp_slb_bandpass_test_k3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k3.coef"; fail; fi

diff -Bb test.epsilon3.ok schurOneMlattice_socp_slb_bandpass_test_epsilon3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon3.coef"; fail; fi

diff -Bb test.p3.ok schurOneMlattice_socp_slb_bandpass_test_p3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p3.coef"; fail; fi

diff -Bb test.c3.ok schurOneMlattice_socp_slb_bandpass_test_c3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c3.coef"; fail; fi

#
# this much worked
#
pass
