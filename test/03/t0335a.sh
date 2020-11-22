#!/bin/sh

prog=sdp_relaxation_schurOneMlattice_bandpass_12_nbits_test.m
depends="sdp_relaxation_schurOneMlattice_bandpass_12_nbits_test.m \
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
k0_sd_Lim = [        0,     1368,        0,     1017, ... 
                     0,      709,        0,      855, ... 
                     0,      609,        0,      515, ... 
                     0,      310,        0,      209, ... 
                     0,       74,        0,       31 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_Lim.ok"; fail; fi

cat > test_c0_sd_Lim.ok << 'EOF'
c0_sd_Lim = [      144,      -26,     -613,     -988, ... 
                  -332,      251,      812,      615, ... 
                    35,     -169,     -163,      -26, ... 
                   -20,      -72,      -52,       10, ... 
                    50,       34,        6,        3, ... 
                    12 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_Lim.ok"; fail; fi

cat > test_k0_sd_sdp.ok << 'EOF'
k0_sd_sdp = [        0,     1364,        0,     1017, ... 
                     0,      709,        0,      854, ... 
                     0,      609,        0,      515, ... 
                     0,      308,        0,      210, ... 
                     0,       74,        0,       31 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_sdp.ok"; fail; fi

cat > test_c0_sd_sdp.ok << 'EOF'
c0_sd_sdp = [      144,      -26,     -612,     -987, ... 
                  -332,      250,      812,      616, ... 
                    35,     -170,     -163,      -25, ... 
                   -21,      -73,      -52,       10, ... 
                    52,       34,        5,        2, ... 
                    10 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_sdp.ok"; fail; fi

cat > test_k0_sd_min.ok << 'EOF'
k0_sd_min = [        0,     1364,        0,     1053, ... 
                     0,      725,        0,      875, ... 
                     0,      612,        0,      514, ... 
                     0,      306,        0,      206, ... 
                     0,       67,        0,       28 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k0_sd_min.ok"; fail; fi

cat > test_c0_sd_min.ok << 'EOF'
c0_sd_min = [      147,      -26,     -610,     -986, ... 
                  -323,      247,      802,      607, ... 
                    29,     -174,     -169,      -26, ... 
                   -14,      -64,      -47,       14, ... 
                    54,       35,        2,       -4, ... 
                     5 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c0_sd_min.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Exact & 0.018051 & -36.0 & & \\
12-bit 4-signed-digit & 0.019398 & -35.4 & 96 & 65 \\
12-bit 4-signed-digit(Lim) & 0.018933 & -35.8 & 102 & 71 \\
12-bit 4-signed-digit(SDP) & 0.020589 & -35.3 & 102 & 71 \\
12-bit 4-signed-digit(min) & 0.015382 & -36.2 & 101 & 70 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="sdp_relaxation_schurOneMlattice_bandpass_12_nbits_test"

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

