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
k2 = [  -0.0519702744,   0.6603092242,  -0.7409678110,   0.3363580975, ... 
        -0.3708914673,   0.3175471628,  -0.2657215122,   0.2053220172, ... 
         0.0496434816,  -0.0929285741,   0.0913030320 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.4630722552,  -0.1938754957,  -1.1823296753,  -0.0908304229, ... 
         0.0203001866,  -0.0711502913,  -0.0098844221,   0.0202855380, ... 
        -0.0101979660,   0.0500941811,  -0.0015559314,  -0.0003535446 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [   0.4582938218,  -0.2291931512,  -0.1989716177,  -0.0927316119, ... 
         -0.0284268590,   0.0704031289,   0.1250872772,  -0.0713975742, ... 
          0.1010430355,  -0.0928278238 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.0869801425,   0.0000000000,  -0.1141717457,   0.0000000000, ... 
         -0.0711284144,   0.0000000000,   0.0047264383,   0.0000000000, ... 
          0.0441776874,   0.0000000000 ]';
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
