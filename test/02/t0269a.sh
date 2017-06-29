#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_allocsd_test.m
depends="schurOneMAPlattice_frm_hilbert_allocsd_test.m test_common.m \
schurOneMAPlattice_frm_hilbert_allocsd_Ito.m \
schurOneMAPlattice_frm_hilbert_allocsd_Lim.m bin2SDul.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertAsq.m \
schurOneMAPlattice_frm_hilbertP.m schurOneMAPlattice_frm_hilbertT.m  \
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
2048*k_Lim_12_bits = [  -1152,   -264,    -96,    -32, ... 
                          -16 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Lim.ok"; fail; fi

cat > test_2_12_u_Lim.ok << 'EOF'
2048*u_Lim_12_bits = [     -2,     -4,    -15,    -24, ... 
                          -64,    -72,   -104,   -116, ... 
                          901 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_u_Lim.ok"; fail; fi

cat > test_2_12_v_Lim.ok << 'EOF'
2048*v_Lim_12_bits = [     16,      9,     15,      4, ... 
                          -16,    -64,   -164,   -644 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_v_Lim.ok"; fail; fi

cat > test_2_12_k_Ito.ok << 'EOF'
2048*k_Ito_12_bits = [  -1152,   -256,    -96,    -32, ... 
                          -16 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_k_Ito.ok"; fail; fi

cat > test_2_12_u_Ito.ok << 'EOF'
2048*u_Ito_12_bits = [     -2,     -4,    -16,    -26, ... 
                          -63,    -70,   -104,   -112, ... 
                          900 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_u_Ito.ok"; fail; fi

cat > test_2_12_v_Ito.ok << 'EOF'
2048*v_Ito_12_bits = [     16,      9,     16,      4, ... 
                          -16,    -64,   -164,   -644 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_v_Ito.ok"; fail; fi

cat > test_3_12_k_Lim.ok << 'EOF'
2048*k_Lim_12_bits = [  -1160,   -266,   -100,    -40, ... 
                          -15 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Lim.ok"; fail; fi

cat > test_3_12_u_Lim.ok << 'EOF'
2048*u_Lim_12_bits = [     -2,     -5,    -15,    -26, ... 
                          -63,    -70,   -106,   -116, ... 
                          901 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_u_Lim.ok"; fail; fi

cat > test_3_12_v_Lim.ok << 'EOF'
2048*v_Lim_12_bits = [     12,      9,     15,      4, ... 
                          -16,    -64,   -165,   -644 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_v_Lim.ok"; fail; fi

cat > test_3_12_k_Ito.ok << 'EOF'
2048*k_Ito_12_bits = [  -1152,   -256,    -96,    -32, ... 
                          -16 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_k_Ito.ok"; fail; fi

cat > test_3_12_u_Ito.ok << 'EOF'
2048*u_Ito_12_bits = [     -2,     -4,    -16,    -26, ... 
                          -63,    -70,   -104,   -112, ... 
                          900 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_u_Ito.ok"; fail; fi

cat > test_3_12_v_Ito.ok << 'EOF'
2048*v_Ito_12_bits = [     13,      9,     16,      4, ... 
                          -16,    -64,   -164,   -644 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_v_Ito.ok"; fail; fi

cat > test_12_nbits_cost.ok << 'EOF'
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_12_nbits_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test_out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


nstr="schurOneMAPlattice_frm_hilbert_allocsd_2_ndigits_12_nbits_test"
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

nstr="schurOneMAPlattice_frm_hilbert_allocsd_3_ndigits_12_nbits_test"
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

