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
schurOneMlattice2H.oct SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
k3 = [   0.0000000000,   0.6647351848,   0.0000000000,   0.4968483495, ... 
         0.0000000000,   0.3434089719,   0.0000000000,   0.4119593974, ... 
         0.0000000000,   0.2869031706,   0.0000000000,   0.2432261065, ... 
         0.0000000000,   0.1429160476,   0.0000000000,   0.0963671380, ... 
         0.0000000000,   0.0328619891,   0.0000000000,   0.0140307031 ];
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
p3 = [   1.1376554999,   1.1376554999,   0.5105428290,   0.5105428290, ... 
         0.8805857051,   0.8805857051,   0.6156232041,   0.6156232041, ... 
         0.9539430056,   0.9539430056,   0.7101069208,   0.7101069208, ... 
         0.9101557877,   0.9101557877,   1.0510205766,   1.0510205766, ... 
         0.9541776109,   0.9541776109,   0.9860663605,   0.9860663605 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi
cat > test.c3.ok << 'EOF'
c3 = [   0.0738597311,  -0.0053193566,  -0.2818652220,  -0.4883973942, ... 
        -0.1788586795,   0.1024292675,   0.3813564143,   0.3060166676, ... 
         0.0249944116,  -0.0784066128,  -0.0781867359,  -0.0119171472, ... 
        -0.0079594061,  -0.0336427477,  -0.0258410243,   0.0042240178, ... 
         0.0238378925,   0.0154625607,   0.0017444157,   0.0012970438, ... 
         0.0063587125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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
