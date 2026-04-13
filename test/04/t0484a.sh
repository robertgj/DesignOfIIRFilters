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
H2Asq.m H2T.m H2P.m H2dAsqdw.m tf2pa.m local_max.m \
qroots.oct complex_zhong_inverse.oct Abcd2H.oct \
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
A1k = [   0.7661143161,   0.8537307624,   0.0889178782,  -0.0187831877, ... 
          0.4838701480,   0.3428157870,  -0.0665245297,   0.3747581420, ... 
          0.0396528943,  -0.3468572258,  -0.0828131556,  -0.0235670545, ... 
         -0.2613899919,  -0.3116648809,  -0.0455659929,  -0.2182534787, ... 
         -0.1901114588,  -0.0426886814,   0.0069249148,  -0.1220206786 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k.ok"; fail; fi

cat > test_A1epsilon.ok << 'EOF'
A1epsilon = [ -1,  1, -1,  1, ... 
              -1, -1,  1,  1, ... 
              -1,  1,  1,  1, ... 
              -1,  1, -1, -1, ... 
               1,  1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon.ok"; fail; fi

cat > test_A2k.ok << 'EOF'
A2k = [   0.7625059676,   0.8124438472,  -0.0491140314,   0.0474589222, ... 
          0.5805576924,   0.2900223655,  -0.3421541432,   0.1574313210, ... 
          0.0451711670,  -0.3026267622,  -0.1075933321,  -0.0378282891, ... 
         -0.2003144022,  -0.2127424939,   0.0281850921,  -0.2052501464, ... 
         -0.2071346461,  -0.0670661674,  -0.0194151122,  -0.1573248371 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k.ok"; fail; fi

cat > test_A2epsilon.ok << 'EOF'
A2epsilon = [ -1,  1,  1, -1, ... 
              -1, -1, -1, -1, ... 
              -1, -1,  1,  1, ... 
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

