#!/bin/sh

prog=schurOneMAPlattice_frm_allocsd_test.m
depends="test/schurOneMAPlattice_frm_allocsd_test.m test_common.m \
schurOneMAPlattice_frm_allocsd_Ito.m \
schurOneMAPlattice_frm_allocsd_Lim.m bin2SDul.m \
schurOneMAPlattice_frm.m \
schurOneMAPlattice_frmEsq.m schurOneMAPlattice_frmAsq.m \
schurOneMAPlattice_frmP.m schurOneMAPlattice_frmT.m  \
schurOneMAPlatticeT.m schurOneMAPlatticeP.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m schurOneMscale.m H2Asq.m H2T.m H2P.m flt2SD.m x2nextra.m \
print_polynomial.m SDadders.m \
schurOneMAPlattice2H.oct schurdecomp.oct schurexpand.oct \
bin2SD.oct bitflip.oct bin2SPT.oct schurOneMlattice2Abcd.oct \
schurOneMlattice2H.oct complex_zhong_inverse.oct"

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

cat > test_2_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [       24,     1224,      -40,     -296, ... 
                         5,      135,        0,      -59, ... 
                         4,       39 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_u_Lim.ok << 'EOF'
u_Lim_12_bits = [     1200,      609,     -129,     -176, ... 
                       128,       64,      -80,       -8, ... 
                        84,      -48,      -20,       28, ... 
                        20,      -16,       -8,       16, ... 
                        -2,      -24,       21,       -4, ... 
                        -8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_u_Lim.ok"; fail; fi

cat > test_2_12_v_Lim.ok << 'EOF'
v_Lim_12_bits = [    -1376,     -544,      276,        8, ... 
                      -128,      104,        8,      -72, ... 
                        70,       -8,      -24,       32, ... 
                         4,      -20,       17,        4, ... 
                       -16,       20,       -6,        0, ... 
                         4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_v_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [       16,     1224,      -40,     -296, ... 
                         4,      128,      -16,      -64, ... 
                         4,       40 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_u_Ito.ok << 'EOF'
u_Ito_12_bits = [     1200,      608,     -128,     -174, ... 
                       108,       64,      -88,       -8, ... 
                        84,      -48,      -16,       28, ... 
                        20,      -20,       -8,       16, ... 
                        -2,      -24,       20,       -4, ... 
                        -8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_u_Ito.ok"; fail; fi

cat > test_2_12_v_Ito.ok << 'EOF'
v_Ito_12_bits = [    -1376,     -544,      276,        8, ... 
                      -132,      104,        8,      -72, ... 
                        72,      -10,      -25,       32, ... 
                         4,      -20,       16,        4, ... 
                       -14,       20,       -8,        1, ... 
                         4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_v_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
k_Lim_12_bits = [       22,     1228,      -40,     -296, ... 
                         5,      135,      -16,      -59, ... 
                         4,       39 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_u_Lim.ok << 'EOF'
u_Lim_12_bits = [     1198,      609,     -129,     -174, ... 
                       112,       64,      -88,       -9, ... 
                        85,      -48,      -20,       27, ... 
                        21,      -20,       -6,       15, ... 
                        -2,      -22,       21,       -3, ... 
                        -7 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_u_Lim.ok"; fail; fi

cat > test_3_12_v_Lim.ok << 'EOF'
v_Lim_12_bits = [    -1376,     -544,      275,        8, ... 
                      -132,      103,        7,      -70, ... 
                        70,      -10,      -25,       31, ... 
                         4,      -21,       17,        3, ... 
                       -14,       19,       -6,        1, ... 
                         5 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_v_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
k_Ito_12_bits = [       16,     1224,      -40,     -296, ... 
                         4,      135,      -16,      -60, ... 
                         4,       40 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_u_Ito.ok << 'EOF'
u_Ito_12_bits = [     1200,      609,     -128,     -174, ... 
                       108,       64,      -88,       -8, ... 
                        85,      -48,      -16,       28, ... 
                        20,      -20,       -8,       16, ... 
                        -2,      -24,       21,       -4, ... 
                        -8 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_u_Ito.ok"; fail; fi

cat > test_3_12_v_Ito.ok << 'EOF'
v_Ito_12_bits = [    -1376,     -544,      276,        8, ... 
                      -133,      104,        8,      -72, ... 
                        72,      -10,      -25,       32, ... 
                         4,      -20,       16,        4, ... 
                       -14,       20,       -6,        1, ... 
                         4 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_v_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


nstr="schurOneMAPlattice_frm_allocsd_2_ndigits_12_nbits_test"
diff -Bb test_2_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Lim.ok"; fail; fi

diff -Bb test_2_12_u_Lim.ok $nstr"_u_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_u_Lim.ok"; fail; fi

diff -Bb test_2_12_v_Lim.ok $nstr"_v_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_v_Lim.ok"; fail; fi

diff -Bb test_2_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_k_Ito.ok"; fail; fi

diff -Bb test_2_12_u_Ito.ok $nstr"_u_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_u_Ito.ok"; fail; fi

diff -Bb test_2_12_v_Ito.ok $nstr"_v_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_v_Ito.ok"; fail; fi

nstr="schurOneMAPlattice_frm_allocsd_3_ndigits_12_nbits_test"
diff -Bb test_3_12_k_Lim.ok $nstr"_k_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Lim.ok"; fail; fi

diff -Bb test_3_12_u_Lim.ok $nstr"_u_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_u_Lim.ok"; fail; fi

diff -Bb test_3_12_v_Lim.ok $nstr"_v_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_v_Lim.ok"; fail; fi

diff -Bb test_3_12_k_Ito.ok $nstr"_k_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_k_Ito.ok"; fail; fi

diff -Bb test_3_12_u_Ito.ok $nstr"_u_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_u_Ito.ok"; fail; fi

diff -Bb test_3_12_v_Ito.ok $nstr"_v_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_v_Ito.ok"; fail; fi

#
# this much worked
#
pass

