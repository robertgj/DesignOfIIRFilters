#!/bin/sh

prog=bitflip_schurOneMlattice_bandpass_test.m
depends="test/bitflip_schurOneMlattice_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
test_common.m delayz.m \
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
k_ex = [   0.0000000000,   0.5571042766,   0.0000000000,   0.3559179199, ... 
           0.0000000000,   0.2900410719,   0.0000000000,   0.4290800588, ... 
           0.0000000000,   0.3121050153,   0.0000000000,   0.3214880321, ... 
           0.0000000000,   0.2071142827,   0.0000000000,   0.1496364166, ... 
           0.0000000000,   0.0607622473,   0.0000000000,   0.0274736202 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.c_ex.ok << 'EOF'
c_ex = [   0.0398765612,  -0.0814064136,  -0.3965417438,  -0.3737012345, ... 
          -0.0052509661,   0.2964924789,   0.4534663332,   0.1803426535, ... 
          -0.0617053104,  -0.0954653923,  -0.0413269516,   0.0053215548, ... 
          -0.0240468326,  -0.0432505440,  -0.0228890699,   0.0203711212, ... 
           0.0189791571,   0.0009201380,  -0.0026519008,   0.0095632109, ... 
           0.0134647981 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [        0,       71,        0,       46, ... 
                0,       37,        0,       55, ... 
                0,       40,        0,       41, ... 
                0,       27,        0,       19, ... 
                0,        8,        0,        4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.c_rd.ok << 'EOF'
c_rd = [        5,      -10,      -51,      -48, ... 
               -1,       38,       58,       23, ... 
               -8,      -12,       -5,        1, ... 
               -3,       -6,       -3,        3, ... 
                2,        0,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [        0,       68,        0,       44, ... 
                0,       35,        0,       53, ... 
                0,       39,        0,       41, ... 
                0,       28,        0,       21, ... 
                0,       10,        0,        4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.c_bf.ok << 'EOF'
c_bf = [        5,      -10,      -51,      -48, ... 
               -1,       38,       58,       23, ... 
               -8,      -12,       -5,        1, ... 
               -3,       -6,       -3,        3, ... 
                2,        0,        0,        1, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [        0,       72,        0,       48, ... 
                0,       36,        0,       56, ... 
                0,       40,        0,       40, ... 
                0,       28,        0,       20, ... 
                0,        8,        0,        4 ]/128;
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
                  0,       36,        0,       56, ... 
                  0,       40,        0,       40, ... 
                  0,       28,        0,       20, ... 
                  0,        9,        0,        3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

cat > test.c_bfsd.ok << 'EOF'
c_bfsd = [        6,      -10,      -48,      -48, ... 
                 -1,       36,       56,       24, ... 
                 -8,      -12,       -5,        1, ... 
                 -3,       -6,       -3,        3, ... 
                  3,        1,        0,        1, ... 
                  1 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsd.ok"; fail; fi

cat > test.k_bfsdl.ok << 'EOF'
k_bfsdl = [        0,       70,        0,       52, ... 
                   0,       34,        0,       52, ... 
                   0,       32,        0,       32, ... 
                   0,       18,        0,       12, ... 
                   0,        4,        0,        0 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdl.ok"; fail; fi

cat > test.c_bfsdl.ok << 'EOF'
c_bfsdl = [        5,      -10,      -52,      -48, ... 
                   0,       40,       58,       24, ... 
                  -8,      -12,       -5,        1, ... 
                  -4,       -6,       -3,        3, ... 
                   4,        0,        0,        1, ... 
                   2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdl.ok"; fail; fi

cat > test.k_bfsdi.ok << 'EOF'
k_bfsdi = [        0,       64,        0,       56, ... 
                   0,       35,        0,       56, ... 
                   0,       34,        0,       41, ... 
                   0,       23,        0,       20, ... 
                   0,        8,        0,        5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdi.ok"; fail; fi

cat > test.c_bfsdi.ok << 'EOF'
c_bfsdi = [        8,      -10,      -52,      -64, ... 
                  -1,       32,       63,       32, ... 
                  -8,      -16,       -4,        0, ... 
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
$23$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Lim.ok"; fail; fi

cat > test.adders_Ito.ok << 'EOF'
$17$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_schurOneMlattice_bandpass_test"

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

