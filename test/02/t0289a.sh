#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_test.m \
../tarczynski_bandpass_R1_test_N0_coef.m \
../tarczynski_bandpass_R1_test_D0_coef.m \
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
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
qroots.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
k3 = [  -0.8819779925,   0.9720595279,  -0.6809223793,   0.7957904491, ... 
        -0.5918788800,   0.8242030694,  -0.6591282107,   0.7616138100, ... 
        -0.5894634045,   0.5193032064,  -0.1853436630,   0.0465082133, ... 
         0.0242030328,   0.0198009633,  -0.0031593646,   0.0117697720, ... 
        -0.0256753340,   0.0297303315,  -0.0182479692,   0.0040375593 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  1,  1,  1, -1, ... 
             -1,  1,  1, -1, ... 
             -1, -1,  1, -1, ... 
             -1, -1,  1, -1, ... 
              1, -1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   0.2504974297,   1.0002971829,   0.1190654906,   0.2732823369, ... 
         0.8104036090,   0.4103372003,   0.1273825516,   0.2810311028, ... 
         0.7639574923,   0.3882575110,   0.6902501039,   0.8326095765, ... 
         0.8722766442,   0.8936501670,   0.9115240130,   0.9144084133, ... 
         0.9252348794,   0.9493035468,   0.9779589568,   0.9959705588 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [  -0.1927560779,  -0.1251201990,  -0.8796562133,  -0.6257463310, ... 
         0.0417666152,   0.9949254913,   1.4659623808,  -0.6654235793, ... 
        -0.1801057425,  -0.0155582699,   0.0143028369,  -0.0234858573, ... 
        -0.0179463428,   0.0183529854,   0.0305094312,   0.0115043387, ... 
        -0.0025893373,   0.0027140534,   0.0088123238,   0.0044021652, ... 
        -0.0090423196 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMlattice_socp_slb_bandpass_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k3.ok $nstr"_k3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k3.coef"; fail; fi

diff -Bb test.epsilon3.ok $nstr"_epsilon3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon3.coef"; fail; fi

diff -Bb test.p3.ok $nstr"_p3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p3.coef"; fail; fi

diff -Bb test.c3.ok $nstr"_c3_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c3.coef"; fail; fi

#
# this much worked
#
pass
