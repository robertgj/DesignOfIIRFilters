#!/bin/sh

prog=bitflip_schurOneMlattice_bandpass_test.m
depends="test/bitflip_schurOneMlattice_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
test_common.m \
bitflip_bandpass_test_common.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
schurdecomp.oct schurexpand.oct bin2SD.oct flt2SD.m x2nextra.m bitflip.oct \
tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m schurOneMlattice2Abcd.oct \
Abcd2tf.m schurOneMscale.m print_polynomial.m bin2SPT.oct schurOneMlatticeAsq.m \
schurOneMlattice2H.oct complex_zhong_inverse.oct H2Asq.m schurOneMlatticeEsq.m \
schurOneMlatticeT.m H2T.m bin2SDul.m schurOneMlattice_allocsd_Lim.m SDadders.m \
schurOneMlattice_allocsd_Ito.m"

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
cat > test.k_ex.ok << 'EOF'
k_ex = [   0.0000000000,   0.7467261815,   0.0000000000,   0.4913437118, ... 
           0.0000000000,   0.3599971419,   0.0000000000,   0.4058257384, ... 
           0.0000000000,   0.3154909602,   0.0000000000,   0.2540403627, ... 
           0.0000000000,   0.1597713931,   0.0000000000,   0.1008416128, ... 
           0.0000000000,   0.0399666402,   0.0000000000,   0.0145991820 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.c_ex.ok << 'EOF'
c_ex = [   0.0776080781,   0.0088465724,  -0.3071614148,  -0.6147777979, ... 
          -0.2587254319,   0.0963877933,   0.2234653249,   0.1950574264, ... 
           0.0575554706,  -0.0948779417,  -0.0515890724,  -0.0062769023, ... 
          -0.0152507861,  -0.0526263473,  -0.0392053765,   0.0010130173, ... 
           0.0220090232,   0.0142734430,   0.0021914368,   0.0054163326, ... 
           0.0119781326 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [        0,       96,        0,       63, ... 
                0,       46,        0,       52, ... 
                0,       40,        0,       33, ... 
                0,       20,        0,       13, ... 
                0,        5,        0,        2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.c_rd.ok << 'EOF'
c_rd = [       10,        1,      -39,      -79, ... 
              -33,       12,       29,       25, ... 
                7,      -12,       -7,       -1, ... 
               -2,       -7,       -5,        0, ... 
                3,        2,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [        0,       96,        0,       62, ... 
                0,       46,        0,       52, ... 
                0,       40,        0,       33, ... 
                0,       20,        0,       13, ... 
                0,        5,        0,        2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.c_bf.ok << 'EOF'
c_bf = [       10,        1,      -39,      -79, ... 
              -33,       13,       29,       25, ... 
                7,      -12,       -7,       -1, ... 
               -2,       -7,       -5,        0, ... 
                3,        2,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [        0,       96,        0,       63, ... 
                0,       48,        0,       48, ... 
                0,       40,        0,       33, ... 
                0,       20,        0,       12, ... 
                0,        5,        0,        2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.c_sd.ok << 'EOF'
c_sd = [       10,        1,      -40,      -80, ... 
              -33,       12,       28,       24, ... 
                7,      -12,       -7,       -1, ... 
               -2,       -7,       -5,        0, ... 
                3,        2,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [        0,       96,        0,       60, ... 
                  0,       48,        0,       48, ... 
                  0,       40,        0,       32, ... 
                  0,       20,        0,       12, ... 
                  0,        5,        0,        2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

cat > test.c_bfsd.ok << 'EOF'
c_bfsd = [       10,        1,      -40,      -80, ... 
                -33,       15,       30,       24, ... 
                  6,      -12,       -7,       -1, ... 
                 -2,       -7,       -5,        0, ... 
                  0,        1,        0,        1, ... 
                  1 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsd.ok"; fail; fi

cat > test.k_bfsdl.ok << 'EOF'
k_bfsdl = [        0,      104,        0,       62, ... 
                   0,       34,        0,       48, ... 
                   0,       24,        0,       32, ... 
                   0,        0,        0,        8, ... 
                   0,        0,        0,        0 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdl.ok"; fail; fi

cat > test.c_bfsdl.ok << 'EOF'
c_bfsdl = [       10,        2,      -39,      -79, ... 
                 -33,       12,       29,       23, ... 
                   4,      -12,       -7,       -1, ... 
                  -2,       -7,       -5,        0, ... 
                   0,        1,        4,        8, ... 
                   2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdl.ok"; fail; fi

cat > test.k_bfsdi.ok << 'EOF'
k_bfsdi = [        0,       96,        0,       64, ... 
                   0,       45,        0,       55, ... 
                   0,       40,        0,       32, ... 
                   0,       18,        0,       13, ... 
                   0,        3,        0,        2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdi.ok"; fail; fi

cat > test.c_bfsdi.ok << 'EOF'
c_bfsdi = [       11,        4,      -32,      -80, ... 
                 -32,       16,       32,       24, ... 
                   2,      -16,       -8,       -1, ... 
                  -2,       -8,       -4,        0, ... 
                   4,        2,        0,        0, ... 
                   0 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdi.ok"; fail; fi

cat > test.adders_bfsd.ok << 'EOF'
$20$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_bfsd.ok"; fail; fi

cat > test.adders_Lim.ok << 'EOF'
$21$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Lim.ok"; fail; fi

cat > test.adders_Ito.ok << 'EOF'
$15$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k_rd.ok bitflip_schurOneMlattice_bandpass_test_k_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi
diff -Bb test.c_rd.ok bitflip_schurOneMlattice_bandpass_test_c_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_rd.ok"; fail; fi
diff -Bb test.k_bf.ok bitflip_schurOneMlattice_bandpass_test_k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi
diff -Bb test.c_bf.ok bitflip_schurOneMlattice_bandpass_test_c_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bf.ok"; fail; fi
diff -Bb test.k_sd.ok bitflip_schurOneMlattice_bandpass_test_k_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi
diff -Bb test.c_sd.ok bitflip_schurOneMlattice_bandpass_test_c_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_sd.ok"; fail; fi
diff -Bb test.k_bfsd.ok bitflip_schurOneMlattice_bandpass_test_k_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi
diff -Bb test.c_bfsd.ok bitflip_schurOneMlattice_bandpass_test_c_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsd.ok"; fail; fi
diff -Bb test.k_bfsdl.ok bitflip_schurOneMlattice_bandpass_test_k_bfsdl_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdl.ok"; fail; fi
diff -Bb test.c_bfsdl.ok bitflip_schurOneMlattice_bandpass_test_c_bfsdl_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdl.ok"; fail; fi
diff -Bb test.k_bfsdi.ok bitflip_schurOneMlattice_bandpass_test_k_bfsdi_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdi.ok"; fail; fi
diff -Bb test.c_bfsdi.ok bitflip_schurOneMlattice_bandpass_test_c_bfsdi_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdi.ok"; fail; fi
diff -Bb test.adders_bfsd.ok bitflip_schurOneMlattice_bandpass_test_adders_bfsd.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_bfsd.ok"; fail; fi
diff -Bb test.adders_Lim.ok bitflip_schurOneMlattice_bandpass_test_adders_Lim.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Lim.ok"; fail; fi
diff -Bb test.adders_Ito.ok bitflip_schurOneMlattice_bandpass_test_adders_Ito.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Ito.ok"; fail; fi

#
# this much worked
#
pass

