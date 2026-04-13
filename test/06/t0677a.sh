#!/bin/sh

prog=schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test.m

depends="test/schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test.m \
test_common.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
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
k2 = [   0.0526397708,   0.7049377525,  -0.7126431904,   0.4087265864, ... 
        -0.3812779611,   0.3649198270,  -0.2575447673,   0.2231343713, ... 
         0.0161117595,  -0.0850138947,   0.0586921049 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.3907999099,  -0.1742852763,  -1.1388181231,  -0.0950937601, ... 
         0.0208288839,  -0.0706842377,  -0.0085472296,   0.0216791379, ... 
        -0.0113961010,   0.0458726664,  -0.0016316960,  -0.0003990049 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [   0.4592078309,  -0.2892485542,  -0.2744631890,  -0.1239488562, ... 
         -0.0079307208,   0.0500762435,   0.1352614387,  -0.0402580899, ... 
          0.0928962513,  -0.0600432268 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.1854589643,   0.0000000000,  -0.1209551860,   0.0000000000, ... 
         -0.0704103819,   0.0000000000,   0.0082434736,   0.0000000000, ... 
          0.0397129261,   0.0000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ck2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test";

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
