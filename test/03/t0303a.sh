#!/bin/sh

prog=branch_bound_schurOneMlattice_bandpass_8_nbits_test.m

depends="branch_bound_schurOneMlattice_bandpass_8_nbits_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m schurOneMscale.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m x2tf.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m x2nextra.m SDadders.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct"
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
cat > test.k.ok << 'EOF'
k_min = [        0,       84,        0,       65, ... 
                 0,       46,        0,       55, ... 
                 0,       38,        0,       33, ... 
                 0,       19,        0,       13, ... 
                 0,        4,        0,        2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi
cat > test.c.ok << 'EOF'
c_min = [       19,       -2,      -72,     -125, ... 
               -46,       26,       98,       80, ... 
                 7,      -21,      -22,       -4, ... 
                -2,       -8,       -6,        1, ... 
                 6,        4,        1,        0, ... 
                 1 ]'/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c.ok"; fail; fi
cat > test.cost.ok << 'EOF'
Exact & 0.0444 & & \\
8-bit 3-signed-digit&0.4738 & 62 & 32 \\
8-bit 3-signed-digit(branch-and-bound)&0.1630 & 63 & 33 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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
