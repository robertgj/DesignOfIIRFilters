#!/bin/sh

prog=schurOneMlatticePipelined_socp_slb_bandpass_test.m

depends="test/schurOneMlatticePipelined_socp_slb_bandpass_test.m \
test_common.m \
../tarczynski_bandpass_R1_test_D0_coef.m \
../tarczynski_bandpass_R1_test_N0_coef.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m \
schurOneMlatticePipelineddAsqdw.m \
schurOneMlatticePipelinedEsq.m \
schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelined_slb.m \
schurOneMlatticePipelined_slb_constraints_are_empty.m \
schurOneMlatticePipelined_socp_mmse.m \
schurOneMlatticePipelined_slb_exchange_constraints.m \
schurOneMlatticePipelined_slb_set_empty_constraints.m \
schurOneMlatticePipelined_slb_show_constraints.m \
schurOneMlatticePipelined_slb_update_constraints.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
tf2schurOneMlatticePipelined.m \
local_max.m tf2pa.m x2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m print_pole_zero.m \
qroots.oct schurdecomp.oct schurexpand.oct Abcd2H.oct Abcd2tf.oct"

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
k2 = [  -0.9260803600,   0.9443042084,  -0.7732202749,   0.6872807039, ... 
        -0.7589787702,   0.7145719812,  -0.7372653171,   0.6446551517, ... 
        -0.5534358534,   0.2977003381,  -0.1342955780,   0.0297190510, ... 
        -0.0264572240,  -0.0214515106,  -0.0034041223,  -0.0039793684, ... 
        -0.0171481990,  -0.0142476718,  -0.0011509336,  -0.0065741623 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.2084745384,  -0.1128119955,  -0.6150807468,  -0.3554894201, ... 
         0.5639886736,   0.6274028552,   0.2905323319,  -0.3090719805, ... 
        -0.3797805075,   0.0023274491,   0.0168255285,  -0.0250973902, ... 
        -0.0138740339,   0.0230723299,   0.0307035598,   0.0091370804, ... 
        -0.0027951985,   0.0030441919,   0.0077530089,   0.0017169289, ... 
        -0.0097472810 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [  -0.8600945263,  -0.7357589680,  -0.5268669197,  -0.5100809647, ... 
         -0.5236423698,  -0.5198738877,  -0.4696403310,  -0.3487943580, ... 
         -0.1591601179,  -0.0421238113,  -0.0023478999,  -0.0029308889, ... 
          0.0020350493,  -0.0132006086,   0.0009098278,  -0.0027442892, ... 
          0.0018852698,  -0.0149189238,  -0.0047058290 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.0819356402,   0.0000000000,  -0.2510776377,   0.0000000000, ... 
          0.4387700180,   0.0000000000,  -0.1846327503,   0.0000000000, ... 
          0.0030995890,   0.0000000000,  -0.0063045313,   0.0000000000, ... 
         -0.0029783465,   0.0000000000,   0.0022797103,   0.0000000000, ... 
         -0.0010672291,   0.0000000000,   0.0020730830 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ck2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlatticePipelined_socp_slb_bandpass_test";

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.ok"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.ok"; fail; fi

diff -Bb test.kk2.ok $nstr"_kk2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.kk2.ok"; fail; fi

diff -Bb test.ck2.ok $nstr"_ck2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.ck2.ok"; fail; fi

#
# this much worked
#
pass
