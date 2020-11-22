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
cat > test.k3.ok << 'EOF'
k3 = [   0.0000000000,   0.6617947141,   0.0000000000,   0.4944165240, ... 
         0.0000000000,   0.3432648305,   0.0000000000,   0.4122651423, ... 
         0.0000000000,   0.2870024618,   0.0000000000,   0.2447372610, ... 
         0.0000000000,   0.1440376927,   0.0000000000,   0.0972044351, ... 
         0.0000000000,   0.0333850125,   0.0000000000,   0.0143579247 ];
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
p3 = [   1.1317464825,   1.1317464825,   0.5105645560,   0.5105645560, ... 
         0.8777888441,   0.8777888441,   0.6137681840,   0.6137681840, ... 
         0.9514188850,   0.9514188850,   0.7081513607,   0.7081513607, ... 
         0.9091089001,   0.9091089001,   1.0510146165,   1.0510146165, ... 
         0.9533660603,   0.9533660603,   0.9857436860,   0.9857436860 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [   0.0719427231,  -0.0121934580,  -0.2984501245,  -0.4832228713, ... 
        -0.1636684512,   0.1209623145,   0.3923071005,   0.2967508961, ... 
         0.0154169737,  -0.0831652371,  -0.0777699353,  -0.0108628623, ... 
        -0.0089396100,  -0.0340321855,  -0.0244726944,   0.0060679850, ... 
         0.0244578526,   0.0149181020,   0.0014257122,   0.0017521858, ... 
         0.0066345188 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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
