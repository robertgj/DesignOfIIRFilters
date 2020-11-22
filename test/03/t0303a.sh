#!/bin/sh

prog=branch_bound_schurOneMlattice_bandpass_8_nbits_test.m

depends="branch_bound_schurOneMlattice_bandpass_8_nbits_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m schurOneMscale.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m x2tf.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m x2nextra.m SDadders.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct \
qroots.m qzsolve.oct"

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
cat > test.k.ok << 'EOF'
k_min = [        0,       88,        0,       63, ... 
                 0,       44,        0,       52, ... 
                 0,       39,        0,       32, ... 
                 0,       20,        0,       14, ... 
                 0,        5,        0,        2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi
cat > test.c.ok << 'EOF'
c_min = [       18,       -3,      -76,     -124, ... 
               -42,       31,      100,       76, ... 
                 4,      -21,      -20,       -3, ... 
                -2,       -9,       -7,        1, ... 
                 6,        5,        1,        0, ... 
                 1 ]'/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi
cat > test.cost.ok << 'EOF'
Exact & 0.0598 & & \\
8-bit 3-signed-digit&0.4404 & 64 & 34 \\
8-bit 3-signed-digit(branch-and-bound)&0.1035 & 62 & 32 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k.ok \
     branch_bound_schurOneMlattice_bandpass_8_nbits_test_k_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi
diff -Bb test.c.ok \
     branch_bound_schurOneMlattice_bandpass_8_nbits_test_c_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi
diff -Bb test.cost.ok \
     branch_bound_schurOneMlattice_bandpass_8_nbits_test_cost.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.cost.ok"; fail; fi

#
# this much worked
#
pass
