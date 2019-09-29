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
k2 = [   0.0000000000,   0.6627692632,   0.0000000000,   0.4986334640, ... 
         0.0000000000,   0.3457645973,   0.0000000000,   0.4187935835, ... 
         0.0000000000,   0.2969059498,   0.0000000000,   0.2514051930, ... 
         0.0000000000,   0.1506513047,   0.0000000000,   0.1021280386, ... 
         0.0000000000,   0.0359565332,   0.0000000000,   0.0149083790 ];
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
p2 = [   1.1203658353,   1.1203658353,   0.5045537504,   0.5045537504, ... 
         0.8723233145,   0.8723233145,   0.6082189555,   0.6082189555, ... 
         0.9502860606,   0.9502860606,   0.6996918719,   0.6996918719, ... 
         0.9046537760,   0.9046537760,   1.0529585015,   1.0529585015, ... 
         0.9503912618,   0.9503912618,   0.9852011123,   0.9852011123 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.0712124945,  -0.0129071460,  -0.2992287234,  -0.4830183690, ... 
        -0.1630620999,   0.1209452330,   0.3944202550,   0.3013080511, ... 
         0.0183288036,  -0.0821162979,  -0.0802912375,  -0.0132150689, ... 
        -0.0094639154,  -0.0345827411,  -0.0255845744,   0.0043968434, ... 
         0.0245252482,   0.0169378061,   0.0030278761,   0.0010306296, ... 
         0.0052643487 ];
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
