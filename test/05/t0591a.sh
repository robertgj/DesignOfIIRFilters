#!/bin/sh

prog=schurNSPAlattice_socp_slb_bandpass_hilbert_test.m
depends="test/schurNSPAlattice_socp_slb_bandpass_hilbert_test.m test_common.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef.m \
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
H2Asq.m H2T.m H2P.m schurNSlatticeFilter.m crossWelch.m \
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
A1s20 = [  -0.4835147972,   0.8577855064,  -0.2930631529,   0.1534784603, ... 
            0.6355419635,  -0.3362409959,   0.1879887361,   0.3701978111, ... 
           -0.3082826569,   0.2168060289 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_coef.m"; fail; fi

cat > test_A1s00_coef.m << 'EOF'
A1s00 = [   0.8732489280,   0.5418701152,   0.9584382165,   0.9862284074, ... 
            0.7900286661,   0.9451300795,   0.9872928943,   0.8896552925, ... 
            0.9594726255,   0.9786372847 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_coef.m"; fail; fi

cat > test_A2s20_coef.m << 'EOF'
A2s20 = [  -0.8208972285,   0.8772816219,  -0.3719924613,   0.1254268247, ... 
            0.6572013158,  -0.3022053884,   0.1863672421,   0.3803157170, ... 
           -0.2871942069,   0.2258944711 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_coef.m"; fail; fi

cat > test_A2s00_coef.m << 'EOF'
A2s00 = [   0.5775587477,   0.4489117405,   0.9276560518,   0.9925386666, ... 
            0.7704117796,   0.9528786574,   0.9805200133,   0.9105718378, ... 
            0.9576274585,   0.9772032484 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurNSPAlattice_socp_slb_bandpass_hilbert_test"

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

