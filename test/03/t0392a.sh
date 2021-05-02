#!/bin/sh

prog=branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.m
depends="branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.m \
test_common.m johanssonOneMlatticeAzp.m johanssonOneMlatticeEsq.m \
tf2schurOneMlattice.m phi2p.m tfp2g.m tf2pa.m local_max.m print_polynomial.m \
flt2SD.m x2nextra.m bin2SDul.m SDadders.m qroots.m schurOneMAPlatticeP.m \
schurOneMscale.m schurOneMAPlattice2Abcd.m H2P.m \
bin2SD.oct bin2SPT.oct qzsolve.oct schurOneMlattice2Abcd.oct \
complex_zhong_inverse.oct schurOneMAPlattice2H.oct schurdecomp.oct \
schurexpand.oct spectralfactor.oct"

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
cat > test_f_min_coef.ok << 'EOF'
f_min = [    -1032,        0,     9224,    16384, ... 
              9224,        0,    -1032 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_f1_coef.ok"; fail; fi

cat > test_k0_min_coef.ok << 'EOF'
k0_min = [    -5632,    29696,    -4736,    24064 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_min_coef.ok"; fail; fi

cat > test_k1_min_coef.ok << 'EOF'
k1_min = [    -5184,    20992 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_min_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_johanssonOneMlattice_bandstop_16_nbits_test"

diff -Bb test_f_min_coef.ok $nstr"_f_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_f_min_coef.ok"; fail; fi

diff -Bb test_k0_min_coef.ok $nstr"_k0_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_min_coef.ok"; fail; fi

diff -Bb test_k1_min_coef.ok $nstr"_k1_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_min_coef.ok"; fail; fi

#
# this much worked
#
pass

