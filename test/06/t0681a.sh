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
local_max.m tf2pa.m x2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m print_pole_zero.m qroots.oct \
schurdecomp.oct schurexpand.oct Abcd2H.oct Abcd2tf.oct"

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
k2 = [  -0.7719984495,   0.8977775677,  -0.6736103588,   0.8053476676, ... 
        -0.6225041528,   0.8080660747,  -0.6697551990,   0.7655184052, ... 
        -0.6176904760,   0.5010459274,  -0.2441351055,   0.0827359901, ... 
         0.0035407340,   0.0065038588,   0.0089853712,   0.0096838067, ... 
         0.0068570701,   0.0035482517,  -0.0034247888,  -0.0062077557 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0745794358,  -0.0633583428,  -0.7084016483,  -0.5712358775, ... 
         0.0067615736,   0.7541619850,   1.2468629758,  -0.5690820247, ... 
        -0.1944692448,  -0.0151314155,  -0.0014342137,   0.0201600529, ... 
        -0.0157697518,   0.0176890344,   0.0279514062,   0.0234900503, ... 
        -0.0026010975,  -0.0127225348,   0.0076285665,   0.0036785895, ... 
        -0.0086489846 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

cat > test.kk2.ok << 'EOF'
kk2 = [  -0.7885841098,  -0.6724462493,  -0.5406802688,  -0.4960339700, ... 
         -0.5149683671,  -0.5310763687,  -0.5270963438,  -0.4860622449, ... 
         -0.3213795471,  -0.1378891898,  -0.0375788486,  -0.0213153198, ... 
          0.0067617871,  -0.0220447864,   0.0138421038,  -0.0273593979, ... 
          0.0091628635,  -0.0077258823,   0.0062875510 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.kk2.ok"; fail; fi

cat > test.ck2.ok << 'EOF'
ck2 = [  -0.0940230721,   0.4587367685,  -0.4632547227,   0.0037509271, ... 
          0.7339052620,  -0.8586520046,  -0.4837498893,   0.1366156622, ... 
         -0.0510773731,  -0.0178948333,   0.0350112971,   0.0001610977, ... 
          0.0027928872,   0.0004984259,   0.0125419525,   0.0000957398, ... 
          0.0141746728,  -0.0000982548,  -0.0007983393 ]';
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
