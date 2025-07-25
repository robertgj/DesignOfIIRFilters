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
k2 = [  -0.9341926423,   0.9938071398,  -0.8608734555,   0.7287291442, ... 
        -0.5247980196,   0.8025832861,  -0.7207420409,   0.7332582892, ... 
        -0.6849880396,   0.6685636179,  -0.6160160808,   0.4907327350, ... 
        -0.2734231510,   0.0400961455,   0.0437162416,  -0.0252402558 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [  1,  1,  1, -1, ... 
              1,  1,  1,  1, ... 
              1,  1,  1,  1, ... 
              1, -1, -1,  1 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   0.3402941461,   1.8448757188,   0.1028184805,   0.3760318250, ... 
         0.9492629063,   1.7004096041,   0.5627271105,   1.3968602003, ... 
         0.5479825975,   1.2673648451,   0.5648463948,   1.1587685024, ... 
         0.6772822099,   0.8966341192,   0.9333362559,   0.9750703880 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0621974520,  -0.0718779472,  -0.6140450945,   0.1627825267, ... 
         0.3774999899,   0.1213972963,  -0.3623005202,  -0.2194449275, ... 
         0.0486608445,   0.0542805171,   0.0242210133,  -0.0027513962, ... 
         0.0417623088,   0.0237590272,   0.0012255891,  -0.0079733647, ... 
         0.0023326647 ]';
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
