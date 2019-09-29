#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_test.m

depends="schurOneMlattice_socp_slb_bandpass_test.m test_common.m \
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
schurOneMlattice_sqp_slb_bandpass_plot.m \
schurOneMlattice2Abcd.oct \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct qroots.m qzsolve.oct SeDuMi_1_3/"

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
k3 = [   0.0000000000,   0.6607687356,   0.0000000000,   0.4961844498, ... 
         0.0000000000,   0.3446716961,   0.0000000000,   0.4124378205, ... 
         0.0000000000,   0.2871493817,   0.0000000000,   0.2460081103, ... 
         0.0000000000,   0.1447594692,   0.0000000000,   0.0977156046, ... 
         0.0000000000,   0.0337525312,   0.0000000000,   0.0145960765 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   1.1263297278,   1.1263297278,   0.5090481953,   0.5090481953, ... 
         0.8772344661,   0.8772344661,   0.6124025884,   0.6124025884, ... 
         0.9494995650,   0.9494995650,   0.7066096418,   0.7066096418, ... 
         0.9083571867,   0.9083571867,   1.0509199625,   1.0509199625, ... 
         0.9527883668,   0.9527883668,   0.9855089082,   0.9855089082 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [   0.0724240404,  -0.0118525165,  -0.2980836411,  -0.4847437660, ... 
        -0.1646802763,   0.1197525597,   0.3924365481,   0.2980550367, ... 
         0.0161421551,  -0.0833806915,  -0.0788119750,  -0.0113576131, ... 
        -0.0084029647,  -0.0331569551,  -0.0240281249,   0.0058774021, ... 
         0.0240604672,   0.0147187825,   0.0013736849,   0.0015782768, ... 
         0.0068331634 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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
