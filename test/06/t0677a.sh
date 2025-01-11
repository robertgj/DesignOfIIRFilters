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
local_max.m tf2pa.m x2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m print_pole_zero.m qroots.m \
schurdecomp.oct schurexpand.oct qzsolve.oct Abcd2H.oct Abcd2tf.oct"

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
k2 = [   0.1385948184,   0.6795761475,  -0.6359944263,   0.3618123487, ... 
        -0.4298844888,   0.3749527899,  -0.2449152497,   0.1688571285, ... 
         0.0071032809,  -0.0599428815,  -0.0047477477 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.3019666482,  -0.2141011747,  -1.0838295839,  -0.0560156900, ... 
         0.0210159268,  -0.0608578283,   0.0005249163,   0.0163843504, ... 
        -0.0101892297,   0.0376584705,  -0.0024909359,  -0.0007898500 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [   0.4354724601,  -0.3011483541,  -0.1733046535,  -0.0624407119, ... 
          0.0096814328,   0.0436395816,   0.0744579813,  -0.0454903272, ... 
          0.0740914610,   0.0000081185 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.1304078475,   0.5469968481,  -0.0826163634,  -0.0361452251, ... 
         -0.0518070235,   0.0023647359,   0.0078465890,   0.0008462962, ... 
          0.0311789379,   0.0000090492 ]';
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
