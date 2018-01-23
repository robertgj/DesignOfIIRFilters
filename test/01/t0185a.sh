#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_test.m

depends="schurOneMlattice_socp_slb_lowpass_test.m test_common.m \
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
schurOneMlattice_socp_slb_lowpass_plot.m \
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
cat > test.k2.ok << 'EOF'
k2 = [  -0.6632301475,   0.6513264680,  -0.5324959391,   0.3544483872, ... 
        -0.1741518210,   0.0475000230,   0.0000000000,   0.0000000000, ... 
         0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.epsilon2.ok << 'EOF'
epsilon2 = [ -1, -1, -1, -1, ... 
              1, -1, -1, -1, ... 
             -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi
cat > test.p2.ok << 'EOF'
p2 = [   1.0207920141,   0.4593330479,   0.9996193941,   0.5521126543, ... 
         0.7997301072,   0.9535763389,   1.0000000000,   1.0000000000, ... 
         1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi
cat > test.c2.ok << 'EOF'
c2 = [   0.4474906376,   0.8866772744,   0.0987277698,  -0.1374366129, ... 
        -0.0510516872,   0.0175758447,   0.0222791564,   0.0003803473, ... 
        -0.0078482368,  -0.0034971737,  -0.0000449277 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k2.ok schurOneMlattice_socp_slb_lowpass_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k2.coef"; fail; fi
diff -Bb test.epsilon2.ok schurOneMlattice_socp_slb_lowpass_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon2.coef"; fail; fi
diff -Bb test.p2.ok schurOneMlattice_socp_slb_lowpass_test_p2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p2.coef"; fail; fi
diff -Bb test.c2.ok schurOneMlattice_socp_slb_lowpass_test_c2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c2.coef"; fail; fi

#
# this much worked
#
pass
