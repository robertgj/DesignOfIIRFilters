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
A1s20 = [  -0.4077483863,   0.5504491435,   0.5561875358,  -0.5406980566, ... 
            0.6550924474,  -0.2327424832,  -0.1036076451,   0.3874943534, ... 
           -0.2737554168,   0.1280532775 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_coef.m"; fail; fi

cat > test_A1s00_coef.m << 'EOF'
A1s00 = [   0.9130223884,   0.8186507827,   0.8521765451,   0.8675824146, ... 
            0.7590997293,   0.9688615054,   0.9889826615,   0.9029780358, ... 
            0.9637418390,   0.9919517025 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_coef.m"; fail; fi

cat > test_A1s02_coef.m << 'EOF'
A1s02 = [   0.4077483863,  -0.5504491435,  -0.5561875358,   0.5406980566, ... 
           -0.6550924474,   0.2327424832,   0.1036076451,  -0.3874943534, ... 
            0.2737554168,  -0.1280532775 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s02_coef.m"; fail; fi

cat > test_A1s22_coef.m << 'EOF'
A1s22 = [   0.9130223884,   0.8186507827,   0.8521765451,   0.8675824146, ... 
            0.7590997293,   0.9688615054,   0.9889826615,   0.9029780358, ... 
            0.9637418390,   0.9919517025 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s22_coef.m"; fail; fi

cat > test_A2s20_coef.m << 'EOF'
A2s20 = [  -0.7568637921,   0.7089747465,   0.4982369666,  -0.6154824399, ... 
            0.6772594217,  -0.1826435801,  -0.0970640223,   0.3951551227, ... 
           -0.2438657261,   0.1438356922 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_coef.m"; fail; fi

cat > test_A2s00_coef.m << 'EOF'
A2s00 = [   0.6328711629,   0.7255084747,   0.8552358058,   0.8262245062, ... 
            0.7193969777,   0.9734900866,   0.9811440994,   0.9369958513, ... 
            0.9622241500,   0.9908034012 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_coef.m"; fail; fi

cat > test_A2s02_coef.m << 'EOF'
A2s02 = [   0.7568637921,  -0.7089747465,  -0.4982369666,   0.6154824399, ... 
           -0.6772594217,   0.1826435801,   0.0970640223,  -0.3951551227, ... 
            0.2438657261,  -0.1438356922 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s02_coef.m"; fail; fi

cat > test_A2s22_coef.m << 'EOF'
A2s22 = [   0.6328711629,   0.7255084747,   0.8552358058,   0.8262245062, ... 
            0.7193969777,   0.9734900866,   0.9811440994,   0.9369958513, ... 
            0.9622241500,   0.9908034012 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s22_coef.m"; fail; fi

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

diff -Bb test_A1s02_coef.m $name"_A1s02_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s02_coef.m"; fail; fi

diff -Bb test_A1s22_coef.m $name"_A1s22_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s22_coef.m"; fail; fi

diff -Bb test_A2s20_coef.m $name"_A2s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_coef.m"; fail; fi

diff -Bb test_A2s00_coef.m $name"_A2s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_coef.m"; fail; fi

diff -Bb test_A2s02_coef.m $name"_A2s02_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s02_coef.m"; fail; fi

diff -Bb test_A2s22_coef.m $name"_A2s22_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s22_coef.m"; fail; fi

#
# this much worked
#
pass

