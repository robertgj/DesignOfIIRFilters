#!/bin/sh

prog=schurOneMR2lattice_socp_slb_bandpass_test.m

depends="test/schurOneMR2lattice_socp_slb_bandpass_test.m \
../tarczynski_bandpass_R2_test_N_coef.m \
../tarczynski_bandpass_R2_test_D_coef.m \
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
schurOneMR2lattice2Abcd.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
qroots.oct schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
schurOneMlattice2H.oct complex_zhong_inverse.oct Abcd2tf.oct"

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
k3 = [   0.0000000000,   0.7407071252,   0.0000000000,   0.4554617561, ... 
         0.0000000000,   0.2564299284,   0.0000000000,   0.4790083394, ... 
         0.0000000000,   0.3263782436,   0.0000000000,   0.4113361288, ... 
         0.0000000000,   0.2516604066,   0.0000000000,   0.2344252744, ... 
         0.0000000000,   0.0930423558,   0.0000000000,   0.0559666672 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   1.1888034447,   1.1888034447,   0.4588201608,   0.4588201608, ... 
         0.7501164658,   0.7501164658,   0.9750724469,   0.9750724469, ... 
         0.5787179580,   0.5787179580,   0.8120683813,   0.8120683813, ... 
         0.5244584204,   0.5244584204,   0.6782736693,   0.6782736693, ... 
         0.8612784223,   0.8612784223,   0.9455152978,   0.9455152978 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [  -0.0867138627,  -0.0415437203,   0.2449599244,   0.6340016445, ... 
         0.3186546908,  -0.0451594884,  -0.2412414155,  -0.2300218719, ... 
        -0.1004549322,   0.0779513607,   0.0408388642,  -0.0027460724, ... 
         0.0122149147,   0.0684005126,   0.0470147320,   0.0058828835, ... 
        -0.0096316201,   0.0009950169,   0.0023545530,   0.0005377425, ... 
        -0.0141897532 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMR2lattice_socp_slb_bandpass_test"

diff -Bb test.k3.ok $nstr"_k3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k3.coef"; fail; fi

diff -Bb test.epsilon3.ok $nstr"_epsilon3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon3.coef"; fail; fi

diff -Bb test.p3.ok $nstr"_p3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p3.coef"; fail; fi

diff -Bb test.c3.ok $nstr"_c3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c3.coef"; fail; fi

#
# this much worked
#
pass
