#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_hilbert_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_hilbert_test.m \
../tarczynski_bandpass_hilbert_test_N0_coef.m \
../tarczynski_bandpass_hilbert_test_D0_coef.m \
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
qroots.oct delayz.m \
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
cat > test.k2.ok << 'EOF'
k2 = [  -0.9484309977,   0.9684730243,  -0.9446922552,   0.5096309461, ... 
        -0.6730330483,   0.7238103425,  -0.8104619340,   0.6537271493, ... 
        -0.7373073318,   0.6406345117,  -0.6686255005,   0.5524776953, ... 
        -0.4306240446,   0.2059231034,  -0.0580646312,   0.0041170564 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  1,  1,  1,  1, ... 
              1,  1, -1, -1, ... 
              1,  1,  1,  1, ... 
              1, -1,  1, -1 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   0.1970901127,   1.2114709046,   0.1533166816,   0.9091213937, ... 
         0.5181410613,   1.1720559424,   0.4691452309,   0.1517961754, ... 
         0.3317290739,   0.8530959628,   0.3992639959,   0.8959423068, ... 
         0.4810328137,   0.7624965821,   0.9396506722,   0.9958913839 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0561964305,  -0.1335282282,  -0.1728811460,  -0.0025596527, ... 
         0.6340018837,   0.2218376578,  -0.3936959290,  -2.1300731266, ... 
         0.0554895353,   0.0792517305,   0.0569091299,  -0.0077065507, ... 
         0.0651304524,   0.0255800220,   0.0020475437,  -0.0067423554, ... 
         0.0019107579 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_bandpass_hilbert_test"

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.coef"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.epsilon2.coef"; fail; fi

diff -Bb test.p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.p2.coef"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.coef"; fail; fi

#
# this much worked
#
pass
