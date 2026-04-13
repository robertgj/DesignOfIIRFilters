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
k3 = [  -0.9185668940,   0.9593801567,  -0.7420782505,   0.6520745346, ... 
        -0.7367979686,   0.7320501264,  -0.7359668753,   0.6546716469, ... 
        -0.5770855076,   0.3010988281,  -0.1301523216,  -0.0020239478, ... 
        -0.0501065101,  -0.0211527254,  -0.0008714031,  -0.0202739829, ... 
        -0.0257666294,  -0.0003322212,  -0.0032746219,  -0.0070879705 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  1,  1,  1, -1, ... 
             -1, -1, -1, -1, ... 
             -1, -1,  1,  1, ... 
              1,  1,  1,  1, ... 
              1,  1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   0.3257302026,   1.5810514492,   0.2276437713,   0.5916237749, ... 
         1.2891911875,   0.5018654463,   1.2759708279,   0.4976216147, ... 
         1.0892787466,   0.5640760928,   0.7696352525,   0.8772670919, ... 
         0.8790444352,   0.9242512546,   0.9440129048,   0.9448358793, ... 
         0.9641896437,   0.9893620436,   0.9896907853,   0.9929369721 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [   0.1918515828,  -0.0746763422,  -0.5515502776,  -0.3500121319, ... 
         0.1088443153,   0.7893156840,   0.0558458815,  -0.4126168418, ... 
        -0.1013516771,   0.0077124160,   0.0135735589,  -0.0213019180, ... 
        -0.0119140807,   0.0227382698,   0.0290338407,   0.0085850415, ... 
        -0.0035332152,   0.0028334447,   0.0076575022,   0.0024372310, ... 
        -0.0089281072 ];
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
