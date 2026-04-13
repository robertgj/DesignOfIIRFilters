#!/bin/sh

prog=bitflip_schurOneMlattice_bandpass_R2_test.m
depends="test/bitflip_schurOneMlattice_bandpass_R2_test.m \
../iir_sqp_slb_bandpass_R2_test_D1_coef.m \
../iir_sqp_slb_bandpass_R2_test_N1_coef.m \
test_common.m delayz.m \
bitflip_bandpass_R2_test_common.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
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
k_ex = [   0.0000000000,   0.5551687654,   0.0000000000,   0.3556319927, ... 
           0.0000000000,   0.2908925021,   0.0000000000,   0.4269206996, ... 
           0.0000000000,   0.3102409880,   0.0000000000,   0.3183364274, ... 
           0.0000000000,   0.2042998573,   0.0000000000,   0.1466137342, ... 
           0.0000000000,   0.0596552429,   0.0000000000,   0.0266181240 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.c_ex.ok << 'EOF'
c_ex = [   0.0408167104,  -0.0794467443,  -0.3935590312,  -0.3743986178, ... 
          -0.0074923278,   0.2939127604,   0.4525844559,   0.1814027155, ... 
          -0.0603736537,  -0.0944237862,  -0.0397600070,   0.0055661196, ... 
          -0.0245964755,  -0.0441443892,  -0.0226994538,   0.0205966766, ... 
           0.0184567547,   0.0001634309,  -0.0023544766,   0.0102474909, ... 
           0.0132437045 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [        0,       71,        0,       46, ... 
                0,       37,        0,       55, ... 
                0,       40,        0,       41, ... 
                0,       26,        0,       19, ... 
                0,        8,        0,        3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.c_rd.ok << 'EOF'
c_rd = [        5,      -10,      -50,      -48, ... 
               -1,       38,       58,       23, ... 
               -8,      -12,       -5,        1, ... 
               -3,       -6,       -3,        3, ... 
                2,        0,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [        0,       68,        0,       44, ... 
                0,       35,        0,       52, ... 
                0,       38,        0,       39, ... 
                0,       26,        0,       19, ... 
                0,        8,        0,        3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.c_bf.ok << 'EOF'
c_bf = [        5,      -10,      -50,      -48, ... 
               -1,       38,       58,       23, ... 
               -8,      -12,       -5,        1, ... 
               -3,       -6,       -3,        2, ... 
                2,        0,        0,        1, ... 
                1 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [        0,       72,        0,       48, ... 
                0,       36,        0,       56, ... 
                0,       40,        0,       40, ... 
                0,       24,        0,       20, ... 
                0,        8,        0,        3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.c_sd.ok << 'EOF'
c_sd = [        5,      -10,      -48,      -48, ... 
               -1,       40,       56,       24, ... 
               -8,      -12,       -5,        1, ... 
               -3,       -6,       -3,        3, ... 
                2,        0,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [        0,       64,        0,       48, ... 
                  0,       34,        0,       56, ... 
                  0,       36,        0,       40, ... 
                  0,       24,        0,       18, ... 
                  0,        7,        0,        3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

cat > test.c_bfsd.ok << 'EOF'
c_bfsd = [        6,      -10,      -48,      -48, ... 
                 -1,       36,       56,       24, ... 
                 -8,      -12,       -5,        1, ... 
                 -3,       -6,       -3,        3, ... 
                  3,        0,        0,        1, ... 
                  2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsd.ok"; fail; fi

cat > test.k_bfsdl.ok << 'EOF'
k_bfsdl = [        0,       72,        0,       40, ... 
                   0,       37,        0,       48, ... 
                   0,       40,        0,       32, ... 
                   0,       32,        0,       17, ... 
                   0,        8,        0,        0 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdl.ok"; fail; fi

cat > test.c_bfsdl.ok << 'EOF'
c_bfsdl = [        5,      -10,      -50,      -48, ... 
                  -1,       37,       56,       21, ... 
                  -8,      -12,       -5,        0, ... 
                  -3,       -6,        0,        5, ... 
                   4,        0,        0,        0, ... 
                   0 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdl.ok"; fail; fi

cat > test.k_bfsdi.ok << 'EOF'
k_bfsdi = [        0,       64,        0,       56, ... 
                   0,       37,        0,       55, ... 
                   0,       36,        0,       40, ... 
                   0,       24,        0,       19, ... 
                   0,        8,        0,        4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdi.ok"; fail; fi

cat > test.c_bfsdi.ok << 'EOF'
c_bfsdi = [        8,      -10,      -48,      -48, ... 
                  -1,       32,       48,       16, ... 
                  -8,      -16,       -4,        1, ... 
                  -4,       -6,       -3,        2, ... 
                   2,        0,        0,        1, ... 
                   2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdi.ok"; fail; fi

cat > test.adders_bfsd.ok << 'EOF'
$23$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_bfsd.ok"; fail; fi

cat > test.adders_Lim.ok << 'EOF'
$22$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Lim.ok"; fail; fi

cat > test.adders_Ito.ok << 'EOF'
$16$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_schurOneMlattice_bandpass_R2_test"

diff -Bb test.k_ex.ok $nstr"_k_ex_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_ex.ok"; fail; fi

diff -Bb test.c_ex.ok $nstr"_c_ex_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_ex.ok"; fail; fi

diff -Bb test.k_rd.ok $nstr"_k_rd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi

diff -Bb test.c_rd.ok $nstr"_c_rd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_rd.ok"; fail; fi

diff -Bb test.k_bf.ok $nstr"_k_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi

diff -Bb test.c_bf.ok $nstr"_c_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bf.ok"; fail; fi

diff -Bb test.k_sd.ok $nstr"_k_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi

diff -Bb test.c_sd.ok $nstr"_c_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_sd.ok"; fail; fi

diff -Bb test.k_bfsd.ok $nstr"_k_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi

diff -Bb test.c_bfsd.ok $nstr"_c_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsd.ok"; fail; fi

diff -Bb test.k_bfsdl.ok $nstr"_k_bfsdl_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdl.ok"; fail; fi

diff -Bb test.c_bfsdl.ok $nstr"_c_bfsdl_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdl.ok"; fail; fi

diff -Bb test.k_bfsdi.ok $nstr"_k_bfsdi_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdi.ok"; fail; fi

diff -Bb test.c_bfsdi.ok $nstr"_c_bfsdi_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdi.ok"; fail; fi

diff -Bb test.adders_bfsd.ok $nstr"_adders_bfsd.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_bfsd.ok"; fail; fi

diff -Bb test.adders_Lim.ok $nstr"_adders_Lim.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Lim.ok"; fail; fi

diff -Bb test.adders_Ito.ok $nstr"_adders_Ito.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Ito.ok"; fail; fi

#
# this much worked
#
pass

