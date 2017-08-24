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
k2 = [   0.0000000000,   0.6700649121,   0.0000000000,   0.5095927841, ... 
         0.0000000000,   0.3530950698,   0.0000000000,   0.4226101122, ... 
         0.0000000000,   0.2998161684,   0.0000000000,   0.2506360582, ... 
         0.0000000000,   0.1500588956,   0.0000000000,   0.0997749565, ... 
         0.0000000000,   0.0337774737,   0.0000000000,   0.0132997738 ];
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
p2 = [   1.1295664714,   1.1295664714,   0.5020643322,   0.5020643322, ... 
         0.8808680317,   0.8808680317,   0.6090696002,   0.6090696002, ... 
         0.9560382815,   0.9560382815,   0.7016820295,   0.7016820295, ... 
         0.9064825147,   0.9064825147,   1.0544477287,   1.0544477287, ... 
         0.9540006881,   0.9540006881,   0.9867875035,   0.9867875035 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.0730774319,  -0.0057147055,  -0.2811046156,  -0.4868041665, ... 
        -0.1756278864,   0.1023744226,   0.3828984087,   0.3093469544, ... 
         0.0262694549,  -0.0786586977,  -0.0820574825,  -0.0143086345, ... 
        -0.0074868593,  -0.0325448194,  -0.0255597241,   0.0035756026, ... 
         0.0243271945,   0.0170796074,   0.0023781365,  -0.0003723380, ... 
         0.0042017367 ];
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
