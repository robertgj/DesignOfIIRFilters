#!/bin/sh

prog=socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test.m
depends="socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test.m \
test_common.m \
schurOneMPAlattice_allocsd_Lim.m \
schurOneMPAlattice_allocsd_Ito.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m flt2SD.m bin2SDul.m x2nextra.m \
SDadders.m Abcd2tf.m H2Asq.m H2T.m H2P.m tf2schurOneMlattice.m schurOneMscale.m \
bin2SD.oct bin2SPT.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_A1k_coef.m << 'EOF'
2048*A1k_min = [   1504,   -656,   -112,    224, ... 
                   -752,    728,   -152,   -126, ... 
                    224,   -164,     66 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D1_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
2048*A2k_min = [    512,   -496,    904,   -104, ... 
                   -447,    740,   -636,    206, ... 
                    116,   -248,    155,    -65 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m \
     socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_A1k_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A2k_coef.m \
     socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_A2k_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi


#
# this much worked
#
pass
