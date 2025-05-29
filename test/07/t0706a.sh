#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_R2_test.m

depends="test/schurOneMlattice_socp_slb_lowpass_R2_test.m test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_socp_slb_lowpass_plot.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m H2Asq.m print_polynomial.m WISEJ.m tf2Abcd.m delayz.m \
qroots.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct Abcd2tf.oct qroots.oct"

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
k2 = [   0.0000000000,   0.2971455815,   0.0000000000,   0.9649373809, ... 
         0.0000000000,  -0.0176330813,   0.0000000000,   0.6266880627, ... 
         0.0000000000,  -0.2811954488,   0.0000000000,   0.2342811916, ... 
         0.0000000000,  -0.1085693370,   0.0000000000,   0.0320248710 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0,  1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   1.3288937338,   1.3288937338,   1.8053105669,   1.8053105669, ... 
         0.2411569284,   0.2411569284,   0.2454474290,   0.2454474290, ... 
         0.5123593764,   0.5123593764,   0.6840328722,   0.6840328722, ... 
         0.8684591016,   0.8684591016,   0.9684718851,   0.9684718851 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.0486057108,   0.0946217386,   0.0620057754,   0.0060095167, ... 
        -0.2968631558,  -0.5836966363,  -0.5210290678,  -0.1121307958, ... 
         0.2236145424,   0.4257078680,   0.3841466326,   0.3520139463, ... 
         0.2012879361,   0.1208302368,   0.0510185781,   0.0174815598, ... 
         0.0032567921 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMlattice_socp_slb_lowpass_R2_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k2.coef"; fail; fi

diff -Bb test.epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon2.coef"; fail; fi

diff -Bb test.p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p2.coef"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c2.coef"; fail; fi

#
# this much worked
#
pass
