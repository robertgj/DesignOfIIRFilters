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
Abcd2tf.m H2Asq.m H2T.m H2P.m qroots.m schurNSlatticeFilter.m crossWelch.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurNSlattice2Abcd.oct Abcd2H.oct qzsolve.oct"

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
A1s20 = [  -0.3980038990,   0.6222893908,   0.4992786490,  -0.5266186155, ... 
            0.6857255162,  -0.2957142021,  -0.0630070262,   0.3885852355, ... 
           -0.2548009056,   0.0855071669 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_coef.m"; fail; fi

cat > test_A1s00_coef.m << 'EOF'
A1s00 = [   0.8886928190,   0.7862367503,   0.8854872714,   0.8639482567, ... 
            0.7061359286,   0.9422441085,   0.9802031671,   0.9550057550, ... 
            0.9878347548,   0.9989673904 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_coef.m"; fail; fi

cat > test_A2s20_coef.m << 'EOF'
A2s20 = [  -0.7654884605,   0.7145547840,   0.4587769615,  -0.6016735619, ... 
            0.7066845904,  -0.2541909553,  -0.0593992154,   0.3869987991, ... 
           -0.2299290365,   0.1067138158 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_coef.m"; fail; fi

cat > test_A2s00_coef.m << 'EOF'
A2s00 = [   0.6343032446,   0.6877283668,   0.9026587369,   0.8377607156, ... 
            0.6836175318,   0.9567212385,   0.9789323607,   0.9502403917, ... 
            0.9917266391,   0.9935832427 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

name=schurNSPAlattice_socp_slb_bandpass_hilbert_test

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1s20_coef.m $name"_A1s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s20_coef.m"; fail; fi

diff -Bb test_A1s00_coef.m $name"_A1s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s00_coef.m"; fail; fi

diff -Bb test_A2s20_coef.m $name"_A2s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_coef.m"; fail; fi

diff -Bb test_A2s00_coef.m $name"_A2s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_coef.m"; fail; fi

#
# this much worked
#
pass

