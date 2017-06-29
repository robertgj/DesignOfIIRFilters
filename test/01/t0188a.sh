#!/bin/sh

prog=schurOneMlattice_sqp_slb_bandpass_test.m

depends="schurOneMlattice_sqp_slb_bandpass_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_sqp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_sqp_slb_bandpass_plot.m \
schurOneMlattice2Abcd.oct schurOneMscale.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct schurOneMlattice2H.oct"
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
cat > test.k2.ok << 'EOF'
k2 = [   0.0000000000,   0.6578120679,   0.0000000000,   0.5164877092, ... 
         0.0000000000,   0.3527537927,   0.0000000000,   0.4280317934, ... 
         0.0000000000,   0.2989556994,   0.0000000000,   0.2525473176, ... 
         0.0000000000,   0.1498954992,   0.0000000000,   0.1010893608, ... 
         0.0000000000,   0.0332806170,   0.0000000000,   0.0134002323 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi
cat > test.p2.ok << 'EOF'
p2 = [   1.0859542638,   1.0859542638,   0.4933739682,   0.4933739682, ... 
         0.8737595176,   0.8737595176,   0.6043900367,   0.6043900367, ... 
         0.9549932244,   0.9549932244,   0.7015778220,   0.7015778220, ... 
         0.9081991060,   0.9081991060,   1.0562679428,   1.0562679428, ... 
         0.9543794437,   0.9543794437,   0.9866883596,   0.9866883596 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.0751717907,  -0.0082427906,  -0.2880852630,  -0.4887366083, ... 
        -0.1709389778,   0.1065369928,   0.3845903475,   0.3074219368, ... 
         0.0242136637,  -0.0804302473,  -0.0844066957,  -0.0154037568, ... 
        -0.0063029471,  -0.0302681729,  -0.0243108556,   0.0037923197, ... 
         0.0245894675,   0.0177004014,   0.0024010069,  -0.0015285861, ... 
         0.0023859122 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k2.ok schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k2.coef"; fail; fi
diff -Bb test.epsilon2.ok schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon2.coef"; fail; fi
diff -Bb test.p2.ok schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p2.coef"; fail; fi
diff -Bb test.c2.ok schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c2.coef"; fail; fi

#
# this much worked
#
pass
