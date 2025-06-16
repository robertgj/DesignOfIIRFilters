#!/bin/sh

prog=schurOneMPAlatticeDelay_socp_slb_lowpass_flat_delay_test.m
depends="test/schurOneMPAlatticeDelay_socp_slb_lowpass_flat_delay_test.m \
 test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
allpass_delay_wise_lowpass.m local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m H2dAsqdw.m WISEJ_DA.m delayz.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.oct"

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
cat > test_m_12_A1k_coef.m << 'EOF'
A1k = [  -0.4390056051,   0.5189533399,   0.2330782093,   0.0196753654, ... 
         -0.0733534421,  -0.0607822860,  -0.0114720768,   0.0212902857, ... 
          0.0197818397,   0.0054837546,  -0.0064443752,  -0.0060322673 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_12_A1k_coef.m"; fail; fi

cat > test_m_5_A1k_coef.m << 'EOF'
A1k = [  -0.3489487656,   0.4588154378,   0.1488021513,  -0.0119950402, ... 
         -0.0327342087 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_5_A1k_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMPAlatticeDelay_socp_slb_lowpass_flat_delay_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_m_12_A1k_coef.m $nstr"_m_12_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_12_A1k_coef.m"; fail; fi

diff -Bb test_m_5_A1k_coef.m $nstr"_m_5_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_5_A1k_coef.m"; fail; fi

#
# this much worked
#
pass

