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
A1kpcls = [  -0.8363596245,   0.9623590905,  -0.6052605318,   0.8491901529, ... 
             -0.6866848124,   0.7786749500,  -0.4118080340,   0.7626733089 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_A1epsilon0.ok << 'EOF'
A1epsilon0 = [  1,  1,  1, -1, ... 
               -1,  1,  1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon0.ok"; fail; fi

cat > test_A2kpcls.ok << 'EOF'
A2kpcls = [  -0.7924234274,   0.9194724999,  -0.8012490601,   0.9006684988, ... 
             -0.7382005150,   0.9957696953,  -0.2482488997,   0.9032722656, ... 
             -0.7547860408,   0.8204101506,  -0.4645807022,   0.6936448981 ]';
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

