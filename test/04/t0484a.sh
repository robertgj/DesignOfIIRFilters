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
A1k = [   0.8414714253,   0.4061229567,  -0.0361621392,   0.2879275053, ... 
         -0.3365366737,  -0.1368834034,   0.4527641501,   0.4549372198, ... 
         -0.0127499924,  -0.1564100626,  -0.0908844613,   0.0069962272, ... 
          0.0435941336,  -0.0148848316,   0.0730116512,   0.0147821388, ... 
         -0.1711078476,   0.0353361546,  -0.0489257318,  -0.0294527709 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k.ok"; fail; fi

cat > test_A1epsilon.ok << 'EOF'
A1epsilon = [  1, -1,  1, -1, ... 
               1, -1,  1, -1, ... 
               1,  1, -1, -1, ... 
              -1,  1, -1, -1, ... 
              -1, -1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon.ok"; fail; fi

cat > test_A2k.ok << 'EOF'
A2k = [   0.8243216801,   0.1406684024,  -0.3021626968,   0.5081936633, ... 
          0.2197032157,   0.0239193127,   0.2677219107,   0.2679750817, ... 
         -0.1090420890,  -0.1669341575,  -0.1131400213,  -0.0185637078, ... 
          0.0566852527,   0.0498976945,   0.1462569676,   0.0665930847, ... 
         -0.1639157341,   0.0142955290,  -0.1129035688,  -0.0663234423 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k.ok"; fail; fi

cat > test_A2epsilon.ok << 'EOF'
A2epsilon = [  1, -1,  1, -1, ... 
               1, -1, -1,  1, ... 
               1,  1, -1,  1, ... 
              -1, -1,  1, -1, ... 
              -1, -1,  1,  1 ];
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

