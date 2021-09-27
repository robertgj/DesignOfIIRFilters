#!/bin/sh

prog=sdp_relaxation_schurOneMlattice_bandpass_10_nbits_test.m
depends="sdp_relaxation_schurOneMlattice_bandpass_10_nbits_test.m \
../schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m \
../schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m \
test_common.m \
sdp_relaxation_schurOneMlattice_mmse.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_allocsd_Lim.m \
schurOneMlattice_allocsd_Ito.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlatticeEsq.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
H2Asq.m H2P.m H2T.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
bin2SD.oct bin2SPT.oct"

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
cat > test_k0_sd_Lim.ok << 'EOF'
k0_sd_Lim = [        0,      344,        0,      254, ... 
                     0,      177,        0,      214, ... 
                     0,      152,        0,      129, ... 
                     0,       76,        0,       52, ... 
                     0,       20,        0,        8 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_Lim.ok"; fail; fi

cat > test_c0_sd_Lim.ok << 'EOF'
c0_sd_Lim = [       36,       -7,     -153,     -247, ... 
                   -84,       63,      204,      154, ... 
                     9,      -42,      -41,       -6, ... 
                    -5,      -18,      -13,        2, ... 
                    13,        8,        1,        1, ... 
                     3 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_Lim.ok"; fail; fi

cat > test_k0_sd_sdp.ok << 'EOF'
k0_sd_sdp = [        0,      340,        0,      255, ... 
                     0,      177,        0,      212, ... 
                     0,      156,        0,      129, ... 
                     0,       76,        0,       52, ... 
                     0,       18,        0,        7 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_sdp.ok"; fail; fi

cat > test_c0_sd_sdp.ok << 'EOF'
c0_sd_sdp = [       36,       -6,     -153,     -247, ... 
                   -82,       63,      202,      153, ... 
                     8,      -42,      -41,       -7, ... 
                    -6,      -19,      -13,        4, ... 
                    13,        9,        1,        0, ... 
                     2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_sdp.ok"; fail; fi

cat > test_k0_sd_min.ok << 'EOF'
k0_sd_min = [        0,      340,        0,      255, ... 
                     0,      177,        0,      216, ... 
                     0,      156,        0,      132, ... 
                     0,       79,        0,       52, ... 
                     0,       17,        0,        6 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_min.ok"; fail; fi

cat > test_c0_sd_min.ok << 'EOF'
c0_sd_min = [       36,       -7,     -154,     -246, ... 
                   -82,       63,      201,      154, ... 
                    11,      -40,      -41,       -8, ... 
                    -5,      -17,      -12,        2, ... 
                    12,       10,        2,        0, ... 
                     2 ]'/512;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.014314 & -36.0 & & \\
10-bit 3-signed-digit & 0.032112 & -35.8 & 73 & 42 \\
10-bit 3-signed-digit(Lim) & 0.027798 & -35.2 & 78 & 47 \\
10-bit 3-signed-digit(SDP) & 0.047554 & -33.0 & 78 & 48 \\
10-bit 3-signed-digit(min) & 0.019727 & -34.5 & 74 & 44 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMlattice_bandpass_10_nbits_test"

diff -Bb test_k0_sd_Lim.ok $nstr"_k0_sd_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_sd_Lim.ok"; fail; fi

diff -Bb test_c0_sd_Lim.ok $nstr"_c0_sd_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0_sd_Lim.ok"; fail; fi

diff -Bb test_k0_sd_sdp.ok $nstr"_k0_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_sd_sdp.ok"; fail; fi

diff -Bb test_c0_sd_sdp.ok $nstr"_c0_sd_sdp_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0_sd_sdp.ok"; fail; fi

diff -Bb test_k0_sd_min.ok $nstr"_k0_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k0_sd_min.ok"; fail; fi

diff -Bb test_c0_sd_min.ok $nstr"_c0_sd_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c0_sd_min.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

