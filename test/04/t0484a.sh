#!/bin/sh

prog=schurOneMPAlattice_socp_slb_multiband_test.m

depends="test/schurOneMPAlattice_socp_slb_multiband_test.m \
../tarczynski_parallel_allpass_multiband_test_Da0_coef.m \
../tarczynski_parallel_allpass_multiband_test_Db0_coef.m \
test_common.m delayz.m print_polynomial.m \
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
schurOneMPAlatticedAsqdw.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m tf2pa.m qroots.oct local_max.m \
complex_zhong_inverse.oct Abcd2H.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
schurOneMAPlattice2H.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
cat > test_A1k.ok << 'EOF'
A1k = [   0.6031454842,   0.5440661698,  -0.0600900891,   0.2166836206, ... 
          0.3743964926,   0.0757780667,   0.2037728036,   0.2688706199, ... 
          0.1116358277,  -0.3415397380,  -0.0347541271,  -0.0222614163, ... 
         -0.3273845496,  -0.2944588806,   0.0117804815,  -0.0902161154, ... 
         -0.3388127467,   0.0060648690,  -0.0669455864,  -0.2332499499 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k.ok"; fail; fi

cat > test_A1epsilon.ok << 'EOF'
A1epsilon = [  1, -1,  1,  1, ... 
               1, -1, -1, -1, ... 
               1, -1,  1,  1, ... 
               1, -1, -1,  1, ... 
               1,  1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon.ok"; fail; fi

cat > test_A2k.ok << 'EOF'
A2k = [   0.5323425476,   0.3492267795,  -0.1070429965,   0.3785968497, ... 
          0.3888445399,  -0.2142788177,  -0.1538847525,   0.1390614828, ... 
          0.1826900850,  -0.2863431742,  -0.0386052167,   0.0208342002, ... 
         -0.2369483874,  -0.2174748725,   0.0388759193,  -0.1059565038, ... 
         -0.3583641905,  -0.0186420995,  -0.1150223657,  -0.2431655821 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k.ok"; fail; fi

cat > test_A2epsilon.ok << 'EOF'
A2epsilon = [  1, -1,  1,  1, ... 
              -1, -1,  1, -1, ... 
               1, -1,  1, -1, ... 
               1, -1, -1,  1, ... 
              -1,  1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_multiband_test"

diff -Bb test_A1k.ok $nstr"_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k.ok"; fail; fi

diff -Bb test_A1epsilon.ok $nstr"_A1epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon.ok"; fail; fi

diff -Bb test_A2k.ok $nstr"_A2k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k.ok"; fail; fi

diff -Bb test_A2epsilon.ok $nstr"_A2epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon.ok"; fail; fi

#
# this much worked
#
pass

