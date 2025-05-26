#!/bin/sh

prog=schurNSPAlattice_socp_slb_lowpass_test.m
depends="test/schurNSPAlattice_socp_slb_lowpass_test.m test_common.m \
../tarczynski_parallel_allpass_test_flat_delay_Da0_coef.m \
../tarczynski_parallel_allpass_test_flat_delay_Db0_coef.m \
schurNSPAlatticeAsq.m \
schurNSPAlatticeT.m \
schurNSPAlatticeP.m \
schurNSPAlatticeEsq.m \
schurNSPAlattice_slb.m \
schurNSPAlattice_slb_constraints_are_empty.m \
schurNSPAlattice_socp_mmse.m \
schurNSPAlattice_slb_exchange_constraints.m \
schurNSPAlattice_slb_set_empty_constraints.m \
schurNSPAlattice_slb_show_constraints.m \
schurNSPAlattice_slb_update_constraints.m \
schurNSPAlattice2tf.m schurNSAPlattice2tf.m schurNSAPlattice2Abcd.m \
tf2schurNSlattice.m local_max.m tf2pa.m print_polynomial.m \
H2Asq.m H2T.m H2P.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurNSlattice2Abcd.oct Abcd2H.oct Abcd2tf.oct qroots.oct"

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
cat > test_A1s20_coef.m << 'EOF'
A1s20 = [   0.7826737409,  -0.0714157913,  -0.2755651077,  -0.1030535490, ... 
           -0.1064124795,   0.2250673343,  -0.1249822938,   0.0241082769, ... 
            0.1772275346,  -0.1635584607,   0.0456102900 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_coef.m"; fail; fi

cat > test_A1s00_coef.m << 'EOF'
A1s00 = [   0.6216764269,   0.9969039294,   0.9611721088,   0.9949938562, ... 
            0.9952219812,   0.9744090381,   0.9927597047,   0.9989781124, ... 
            0.9841483964,   0.9869941035,   0.9989616988 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_coef.m"; fail; fi

cat > test_A2s20_coef.m << 'EOF'
A2s20 = [   0.3671728947,  -0.2966842868,   0.2226927352,   0.2139762162, ... 
           -0.0179779931,   0.0463578909,  -0.1985750068,   0.1844890161, ... 
            0.0090345416,  -0.1826197059,   0.1437902801,  -0.0578143019 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_coef.m"; fail; fi

cat > test_A2s00_coef.m << 'EOF'
A2s00 = [   0.9295828394,   0.9539685973,   0.9750115069,   0.9773007370, ... 
            0.9989562089,   0.9987933449,   0.9816924285,   0.9832933047, ... 
            0.9989553810,   0.9835198952,   0.9897642702,   0.9987365353 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=schurNSPAlattice_socp_slb_lowpass_test

diff -Bb test_A1s20_coef.m $nstr"_A1s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s20_coef.m"; fail; fi

diff -Bb test_A1s00_coef.m $nstr"_A1s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s00_coef.m"; fail; fi

diff -Bb test_A2s20_coef.m $nstr"_A2s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_coef.m"; fail; fi

diff -Bb test_A2s00_coef.m $nstr"_A2s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_coef.m"; fail; fi

#
# this much worked
#
pass

