#!/bin/sh

prog=ellip20OneMPAMB_test.m

depends="test/ellip20OneMPAMB_test.m test_common.m print_polynomial.m \
phi2p.m tfp2g.m tf2x.m zp2x.m x2tf.m qroots.oct tf2schurOneMlattice.m flt2SD.m \
schurOneMscale.m x2nextra.m schurOneMlatticeRetimedNoiseGain.m p2n60.m \
schurOneMlatticeFilter.m crossWelch.m KW.m schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct spectralfactor.oct Abcd2H.oct bin2SD.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct"

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
cat > test_k1.ok << 'EOF'
k1 = [  -0.6252078819,   0.8595752205,  -0.7983590805,   0.8691968255, ... 
        -0.7206949261,   0.7330239299,  -0.5614024408,   0.6586083192 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1.ok"; fail; fi

cat > test_k2.ok << 'EOF'
k2 = [  -0.5421406489,   0.9243373160,  -0.8495312899,   0.8788656380, ... 
        -0.8294636879,   0.8679025748,  -0.4446014672,   0.8888617122, ... 
        -0.6402270264,   0.7422426326,  -0.6485254715,   0.6141347472 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2.ok"; fail; fi

cat > test_epsilon1.ok << 'EOF'
epsilon1 = [ -1, -1,  1,  1, ... 
              1,  1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1.ok"; fail; fi

cat > test_epsilon2.ok << 'EOF'
epsilon2 = [  1,  1,  1,  1, ... 
              1,  1,  1,  1, ... 
              1, -1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2.ok"; fail; fi

cat > test_k1sd.ok << 'EOF'
k1sd = [      -80,      110,     -102,      111, ... 
              -92,       94,      -72,       84 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1sd.ok"; fail; fi

cat > test_k2sd.ok << 'EOF'
k2sd = [      -69,      118,     -109,      112, ... 
             -106,      111,      -57,      114, ... 
              -82,       95,      -83,       79 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2sd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1.ok ellip20OneMPAMB_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1.ok"; fail; fi

diff -Bb test_k2.ok ellip20OneMPAMB_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2.ok"; fail; fi

diff -Bb test_epsilon1.ok ellip20OneMPAMB_test_epsilon1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon1.ok"; fail; fi

diff -Bb test_epsilon2.ok ellip20OneMPAMB_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2.ok"; fail; fi

diff -Bb test_k1sd.ok ellip20OneMPAMB_test_k1sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1sd.ok"; fail; fi

diff -Bb test_k2sd.ok ellip20OneMPAMB_test_k2sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2sd.ok"; fail; fi

#
# this much worked
#
pass

