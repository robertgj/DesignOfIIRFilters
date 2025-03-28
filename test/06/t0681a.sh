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
k2 = [  -0.7732552141,   0.8924652873,  -0.6768976385,   0.8078651061, ... 
        -0.6160082572,   0.8106403286,  -0.6716700024,   0.7670437994, ... 
        -0.6224364997,   0.5020684105,  -0.2420046076,   0.0825660294, ... 
         0.0083760162,   0.0050786411,   0.0105093992,   0.0119594503, ... 
         0.0063017769,   0.0056047300,  -0.0047177095,  -0.0060632591 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0847547765,  -0.0629943999,  -0.7086003038,  -0.5713757353, ... 
         0.0066337172,   0.7532718541,   1.2479313248,  -0.5675889276, ... 
        -0.1952132846,  -0.0138995769,  -0.0010654616,   0.0209749603, ... 
        -0.0155210901,   0.0184747433,   0.0283358552,   0.0239095902, ... 
        -0.0026288105,  -0.0131355060,   0.0075055110,   0.0035298704, ... 
        -0.0089283144 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [  -0.7776703164,  -0.6715422983,  -0.5461494415,  -0.4978856637, ... 
         -0.5139685801,  -0.5317592147,  -0.5301385544,  -0.4895238451, ... 
         -0.3256998659,  -0.1380772341,  -0.0416771647,  -0.0169295799, ... 
          0.0062884007,  -0.0223263149,   0.0108369126,  -0.0294629737, ... 
          0.0063041742,  -0.0076993247,   0.0055016976 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.0975674484,   0.0000000000,  -0.4638758589,   0.0000000000, ... 
          0.7315975997,   0.0000000000,  -0.4837420662,   0.0000000000, ... 
         -0.0514568268,   0.0000000000,   0.0355679288,   0.0000000000, ... 
          0.0034167758,   0.0000000000,   0.0128971272,   0.0000000000, ... 
          0.0144812443,   0.0000000000,  -0.0008743842 ]';
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
