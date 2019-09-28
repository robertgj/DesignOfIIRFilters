#!/bin/sh

prog=johanssonOneMlattice_socp_slb_bandstop_test.m
depends="johanssonOneMlattice_socp_slb_bandstop_test.m \
test_common.m \
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
qroots.m schurOneMAPlatticeP.m schurOneMscale.m schurOneMAPlattice2Abcd.m H2P.m \
qzsolve.oct schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
schurOneMAPlattice2H.oct schurdecomp.oct schurexpand.oct spectralfactor.oct \
SeDuMi_1_3"

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
cat > test_f_coef.ok << 'EOF'
f = [  -0.0278384479,   0.0071177162,   0.2778376394,   0.4857649475, ... 
        0.2778376394,   0.0071177162,  -0.0278384479 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_f_coef.ok"; fail; fi

cat > test_k0_coef.ok << 'EOF'
k0 = [  -0.1820024209,   0.8447713007,  -0.1350137135,   0.6598419792 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_coef.ok"; fail; fi

cat > test_k1_coef.ok << 'EOF'
k1 = [  -0.1575683846,   0.5437545726 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
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

