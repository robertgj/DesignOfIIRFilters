#!/bin/sh

prog=schurOneMPAlattice_socp_slb_multiband_test.m

depends="schurOneMPAlattice_socp_slb_multiband_test.m \
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
schurOneMscale.m \
H2Asq.m H2T.m H2P.m tf2pa.m qroots.m local_max.m \
complex_zhong_inverse.oct qzsolve.oct Abcd2H.oct \
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
A1kpcls = [  -0.3571411942,   0.6406138654,   0.6587934451,  -0.3653053163, ... 
              0.1856679828,   0.3342044392,  -0.1637699402,   0.1830185162, ... 
              0.4458081926,  -0.0930051847,   0.2564508624,   0.0817664826 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_A1epsilon0.ok << 'EOF'
A1epsilon0 = [ -1, -1,  1,  1, ... 
               -1, -1, -1, -1, ... 
                1, -1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon0.ok"; fail; fi

cat > test_A2kpcls.ok << 'EOF'
A2kpcls = [  -0.1249868379,   0.6497204047,   0.6161901287,  -0.3292992722, ... 
              0.3155323319,   0.4113243765,  -0.0914359646,   0.2591481490, ... 
              0.4778216904,  -0.1079488822,   0.2154356508,   0.0890503535 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2kpcls.ok"; fail; fi

cat > test_A2epsilon0.ok << 'EOF'
A2epsilon0 = [  1,  1, -1, -1, ... 
               -1,  1, -1, -1, ... 
                1,  1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_multiband_test"

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

