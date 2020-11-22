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
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct qroots.m qzsolve.oct"

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
k2 = [   0.0000000000,   0.6672941040,   0.0000000000,   0.4964339512, ... 
         0.0000000000,   0.3462541958,   0.0000000000,   0.4174447450, ... 
         0.0000000000,   0.2972265849,   0.0000000000,   0.2512380752, ... 
         0.0000000000,   0.1512067104,   0.0000000000,   0.1021213819, ... 
         0.0000000000,   0.0362873774,   0.0000000000,   0.0150434464 ];
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
p2 = [   1.1347028210,   1.1347028210,   0.5068813077,   0.5068813077, ... 
         0.8737895201,   0.8737895201,   0.6089024956,   0.6089024956, ... 
         0.9498002094,   0.9498002094,   0.6990882505,   0.6990882505, ... 
         0.9037121116,   0.9037121116,   1.0524604636,   1.0524604636, ... 
         0.9499481273,   0.9499481273,   0.9850680230,   0.9850680230 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.0704220318,  -0.0128131535,  -0.2992902741,  -0.4821898211, ... 
        -0.1624772574,   0.1224197607,   0.3957944438,   0.3003806315, ... 
         0.0171913758,  -0.0825265596,  -0.0795022588,  -0.0125414131, ... 
        -0.0099076456,  -0.0352745634,  -0.0255810623,   0.0048309905, ... 
         0.0246323253,   0.0165313769,   0.0027523217,   0.0012900360, ... 
         0.0058052079 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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
