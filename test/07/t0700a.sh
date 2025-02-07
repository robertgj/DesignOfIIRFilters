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
qroots.m delayz.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct qzsolve.oct Abcd2tf.oct"

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
k2 = [   0.0000000000,   0.7002221988,   0.0000000000,   0.4261657350, ... 
         0.0000000000,   0.2885854078,   0.0000000000,   0.5012636273, ... 
         0.0000000000,   0.3357849475,   0.0000000000,   0.4272447152, ... 
         0.0000000000,   0.2614877065,   0.0000000000,   0.2478936761, ... 
         0.0000000000,   0.0973780409,   0.0000000000,   0.0606826680 ]';
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
p2 = [   1.0989710890,   1.0989710890,   0.4614590432,   0.4614590432, ... 
         0.7274864715,   0.7274864715,   0.9790844239,   0.9790844239, ... 
         0.5643222597,   0.5643222597,   0.8002784039,   0.8002784039, ... 
         0.5069631914,   0.5069631914,   0.6625811476,   0.6625811476, ... 
         0.8534699734,   0.8534699734,   0.9410515877,   0.9410515877 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0420612092,   0.0981691982,   0.4723991775,   0.2648945350, ... 
        -0.1744843754,  -0.4392191786,  -0.2487978085,  -0.0237349575, ... 
         0.1978901726,   0.1601631402,   0.0323134012,   0.0040107183, ... 
         0.0668125728,   0.0513309101,   0.0013144448,  -0.0356741452, ... 
        -0.0119426176,  -0.0031990654,  -0.0052562259,  -0.0139012685, ... 
        -0.0067284763 ]';
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
