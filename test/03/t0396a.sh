#!/bin/sh

prog=johanssonOneMlattice_socp_slb_bandstop_test.m
depends="test/johanssonOneMlattice_socp_slb_bandstop_test.m \
test_common.m \
../johansson_cascade_allpass_bandstop_test_bsA0_coef.m \
../johansson_cascade_allpass_bandstop_test_bsA1_coef.m \
../johansson_cascade_allpass_bandstop_test_f1_coef.m \
johanssonOneMlatticeAzp.m \
johanssonOneMlatticeEsq.m \
johanssonOneMlattice_socp_mmse.m \
johanssonOneMlattice_slb.m \
johanssonOneMlattice_slb_update_constraints.m \
johanssonOneMlattice_slb_exchange_constraints.m \
johanssonOneMlattice_slb_show_constraints.m \
johanssonOneMlattice_slb_set_empty_constraints.m \
johanssonOneMlattice_slb_constraints_are_empty.m \
tf2schurOneMlattice.m phi2p.m tfp2g.m tf2pa.m local_max.m print_polynomial.m \
qroots.oct schurOneMAPlatticeP.m schurOneMscale.m schurOneMAPlattice2Abcd.m H2P.m \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
schurOneMAPlattice2H.oct schurdecomp.oct schurexpand.oct spectralfactor.oct"

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
cat > test_f_coef.ok << 'EOF'
f = [  -0.0280871068,   0.0065333941,   0.2780868425,   0.4869336766, ... 
        0.2780868425,   0.0065333941,  -0.0280871068 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_f_coef.ok"; fail; fi

cat > test_k0_coef.ok << 'EOF'
k0 = [  -0.1784512812,   0.8243132570,  -0.1410010448,   0.6462785192 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_coef.ok"; fail; fi

cat > test_k1_coef.ok << 'EOF'
k1 = [  -0.1519187362,   0.5060944397 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="johanssonOneMlattice_socp_slb_bandstop_test"

diff -Bb test_f_coef.ok $nstr"_f_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_f_coef.ok"; fail; fi

diff -Bb test_k0_coef.ok $nstr"_k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_coef.ok"; fail; fi

diff -Bb test_k1_coef.ok $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.ok"; fail; fi

#
# this much worked
#
pass

