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
k3 = [   0.0000000000,   0.7397152222,   0.0000000000,   0.4544367025, ... 
         0.0000000000,   0.2562888117,   0.0000000000,   0.4790518007, ... 
         0.0000000000,   0.3267156653,   0.0000000000,   0.4115581409, ... 
         0.0000000000,   0.2520363779,   0.0000000000,   0.2346150129, ... 
         0.0000000000,   0.0932190281,   0.0000000000,   0.0559853590 ];
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
p3 = [   1.1868985633,   1.1868985633,   0.4590911358,   0.4590911358, ... 
         0.7495899364,   0.7495899364,   0.9742408504,   0.9742408504, ... 
         0.5781917813,   0.5781917813,   0.8116365343,   0.8116365343, ... 
         0.5240394494,   0.5240394494,   0.6780039396,   0.6780039396, ... 
         0.8611087942,   0.8611087942,   0.9454975690,   0.9454975690 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [  -0.0862776853,  -0.0416408600,   0.2463030260,   0.6337092508, ... 
         0.3188307030,  -0.0451247265,  -0.2416205385,  -0.2299924650, ... 
        -0.1000897798,   0.0790169743,   0.0405281471,  -0.0023029170, ... 
         0.0113820725,   0.0694472719,   0.0460850969,   0.0066951811, ... 
        -0.0104628535,   0.0011884331,   0.0026604617,   0.0000420009, ... 
        -0.0139862926 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k3.ok schurOneMR2lattice_socp_slb_bandpass_test_k3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k3.coef"; fail; fi

diff -Bb test.epsilon3.ok schurOneMR2lattice_socp_slb_bandpass_test_epsilon3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon3.coef"; fail; fi

diff -Bb test.p3.ok schurOneMR2lattice_socp_slb_bandpass_test_p3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p3.coef"; fail; fi

diff -Bb test.c3.ok schurOneMR2lattice_socp_slb_bandpass_test_c3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c3.coef"; fail; fi

#
# this much worked
#
pass
