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
k3 = [   0.0000000000,   0.6692648314,   0.0000000000,   0.4959796827, ... 
         0.0000000000,   0.3436183402,   0.0000000000,   0.4103001601, ... 
         0.0000000000,   0.2876829650,   0.0000000000,   0.2418099043, ... 
         0.0000000000,   0.1424848603,   0.0000000000,   0.0956498173, ... 
         0.0000000000,   0.0327011329,   0.0000000000,   0.0137473718 ];
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
p3 = [   1.1537663035,   1.1537663035,   0.5135649996,   0.5135649996, ... 
         0.8847778547,   0.8847778547,   0.6184071486,   0.6184071486, ... 
         0.9563454015,   0.9563454015,   0.7112904276,   0.7112904276, ... 
         0.9103019442,   0.9103019442,   1.0507267743,   1.0507267743, ... 
         0.9546017560,   0.9546017560,   0.9863458374,   0.9863458374 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [   0.0725101701,  -0.0058569885,  -0.2810144356,  -0.4849923199, ... 
        -0.1776936102,   0.1019970848,   0.3788693905,   0.3039155676, ... 
         0.0247282061,  -0.0779594905,  -0.0778496506,  -0.0117918198, ... 
        -0.0081461303,  -0.0336303545,  -0.0259002675,   0.0040154799, ... 
         0.0236467905,   0.0155543945,   0.0019222902,   0.0014366676, ... 
         0.0060817048 ];
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
