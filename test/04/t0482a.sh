#!/bin/sh

prog=schurOneMPAlattice_socp_slb_lowpass_to_multiband_test.m

depends="schurOneMPAlattice_socp_slb_lowpass_to_multiband_test.m \
test_common.m print_polynomial.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_socp_slb_lowpass_plot.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMlatticeRetimedNoiseGain.m \
schurOneMlatticeFilter.m \
schurOneMscale.m \
H2Asq.m H2T.m H2P.m phi2p.m tfp2g.m tf2x.m zp2x.m x2tf.m tf2pa.m qroots.m \
local_max.m \
complex_zhong_inverse.oct spectralfactor.oct qzsolve.oct Abcd2H.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
schurOneMAPlattice2H.oct schurOneMlattice2H.oct"

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
cat > test_A1kpcls.ok << 'EOF'
A1kpcls = [  -0.8290768940,   0.9644502223,  -0.5939881399,   0.8530250832, ... 
             -0.7059969075,   0.7668998763,  -0.4166052776,   0.7796642557 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_A1epsilon0.ok << 'EOF'
A1epsilon0 = [  1,  1,  1, -1, ... 
               -1,  1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon0.ok"; fail; fi

cat > test_A2kpcls.ok << 'EOF'
A2kpcls = [  -0.8032801176,   0.8926899337,  -0.8051006933,   0.8797532438, ... 
             -0.7318895350,   0.9910583254,  -0.2458625566,   0.9132592781, ... 
             -0.7554055981,   0.8198202091,  -0.4677824575,   0.7031817659 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2kpcls.ok"; fail; fi

cat > test_A2epsilon0.ok << 'EOF'
A2epsilon0 = [  1,  1,  1, -1, ... 
               -1,  1,  1, -1, ... 
                1,  1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_lowpass_to_multiband_test"

diff -Bb test_A1kpcls.ok $nstr"_A1kpcls_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1kpcls.ok"; fail; fi

diff -Bb test_A1epsilon0.ok $nstr"_A1epsilon0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon0.ok"; fail; fi

diff -Bb test_A2kpcls.ok $nstr"_A2kpcls_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2kpcls.ok"; fail; fi

diff -Bb test_A2epsilon0.ok $nstr"_A2epsilon0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon0.ok"; fail; fi

#
# this much worked
#
pass

