#!/bin/sh

prog=schurOneMlattice_bandpass_allocsd_test.m
depends="schurOneMlattice_bandpass_allocsd_test.m test_common.m \
schurOneMlattice_bandpass_10_nbits_common.m \
schurOneMlattice_allocsd_Ito.m schurOneMlattice_allocsd_Lim.m bin2SDul.m \
schurOneMlatticeEsq.m H2Asq.m schurOneMlatticeAsq.m schurOneMlatticeT.m \
schurOneMlatticeP.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
schurOneMlatticeNoiseGain.m tf2schurOneMlattice.m Abcd2tf.m schurOneMscale.m \
print_polynomial.m H2T.m H2P.m flt2SD.m x2nextra.m schurOneMR2lattice2Abcd.m \
KW.m SDadders.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bitflip.oct bin2SPT.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct complex_zhong_inverse.oct"

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
cat > test_2_12_k_Lim.ok << 'EOF'
2048*k_Lim_12_bits = [      0,   1344,      0,   1058, ... 
                            0,    736,      0,    896, ... 
                            0,    608,      0,    517, ... 
                            0,    320,      0,    208, ... 
                            0,     64,      0,     32 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi
cat > test_2_12_c_Lim.ok << 'EOF'
2048*c_Lim_12_bits = [    160,    -17,   -592,  -1000, ... 
                         -352,    216,    784,    640, ... 
                           64,   -164,   -176,    -32, ... 
                          -16,    -62,    -48,      0, ... 
                           64,     32,      0,      0, ... 
                            4 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Lim.ok"; fail; fi
cat > test_2_12_k_Ito.ok << 'EOF'
2048*k_Ito_12_bits = [      0,   1344,      0,   1056, ... 
                            0,    736,      0,    880, ... 
                            0,    612,      0,    516, ... 
                            0,    304,      0,    208, ... 
                            0,     68,      0,     28 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi
cat > test_2_12_c_Ito.ok << 'EOF'
2048*c_Ito_12_bits = [    160,    -16,   -576,  -1024, ... 
                         -352,    224,    784,    640, ... 
                           48,   -160,   -160,    -32, ... 
                          -16,    -64,    -48,      8, ... 
                           48,     36,      4,     -4, ... 
                            4 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_c_Ito.ok"; fail; fi
cat > test_3_12_k_Lim.ok << 'EOF'
2048*k_Lim_12_bits = [      0,   1348,      0,   1058, ... 
                            0,    720,      0,    880, ... 
                            0,    612,      0,    517, ... 
                            0,    304,      0,    207, ... 
                            0,     68,      0,     28 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi
cat > test_3_12_c_Lim.ok << 'EOF'
2048*c_Lim_12_bits = [    152,    -17,   -590,  -1001, ... 
                         -350,    218,    788,    632, ... 
                           48,   -165,   -172,    -32, ... 
                          -12,    -62,    -50,      8, ... 
                           48,     36,      4,     -4, ... 
                            5 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Lim.ok"; fail; fi
cat > test_3_12_k_Ito.ok << 'EOF'
2048*k_Ito_12_bits = [      0,   1344,      0,   1056, ... 
                            0,    720,      0,    876, ... 
                            0,    612,      0,    517, ... 
                            0,    308,      0,    208, ... 
                            0,     68,      0,     28 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi
cat > test_3_12_c_Ito.ok << 'EOF'
2048*c_Ito_12_bits = [    154,    -16,   -592,  -1008, ... 
                         -352,    216,    784,    632, ... 
                           48,   -164,   -176,    -32, ... 
                          -16,    -62,    -48,      8, ... 
                           50,     36,      5,     -4, ... 
                            5 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_c_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test_out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_bandpass_allocsd_2_ndigits_12_nbits_test"
diff -Bb test_2_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Lim.ok"; fail; fi
diff -Bb test_2_12_c_Lim.ok $nstr"_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Lim.ok"; fail; fi
diff -Bb test_2_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Ito.ok"; fail; fi
diff -Bb test_2_12_c_Ito.ok $nstr"_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_c_Ito.ok"; fail; fi
nstr="schurOneMlattice_bandpass_allocsd_3_ndigits_12_nbits_test"
diff -Bb test_3_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Lim.ok"; fail; fi
diff -Bb test_3_12_c_Lim.ok $nstr"_c_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Lim.ok"; fail; fi
diff -Bb test_3_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Ito.ok"; fail; fi
diff -Bb test_3_12_c_Ito.ok $nstr"_c_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_c_Ito.ok"; fail; fi

#
# this much worked
#
pass

