#!/bin/sh

prog=johanssonOneMlattice_socp_mmse_test.m
depends="johanssonOneMlattice_socp_mmse_test.m \
test_common.m \
johanssonOneMlatticeAzp.m \
johanssonOneMlatticeEsq.m \
johanssonOneMlattice_socp_mmse.m \
johanssonOneMlattice_slb_set_empty_constraints.m \
tf2schurOneMlattice.m phi2p.m tfp2g.m tf2pa.m local_max.m print_polynomial.m \
qroots.m schurOneMAPlatticeP.m schurOneMscale.m schurOneMAPlattice2Abcd.m H2P.m \
qzsolve.oct schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
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
cat > test_fM_coef.ok << 'EOF'
fM = [  -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_f1_coef.ok"; fail; fi

cat > test_k0_coef.ok << 'EOF'
k0 = [  -0.1730385637,   0.9074570246,  -0.1436602088,   0.7284633026 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_coef.ok"; fail; fi

cat > test_k1_coef.ok << 'EOF'
k1 = [  -0.1583844403,   0.6383172372 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="johanssonOneMlattice_socp_mmse_test"

diff -Bb test_fM_coef.ok $nstr"_fM_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_fM_coef.ok"; fail; fi

diff -Bb test_k0_coef.ok $nstr"_k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_coef.ok"; fail; fi

diff -Bb test_k1_coef.ok $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.ok"; fail; fi

#
# this much worked
#
pass

