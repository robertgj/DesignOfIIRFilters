#!/bin/sh

prog=bitflip_directIIR_bandpass_R2_test.m
depends="test/bitflip_directIIR_bandpass_R2_test.m \
../iir_sqp_slb_bandpass_R2_test_D1_coef.m \
../iir_sqp_slb_bandpass_R2_test_N1_coef.m \
test_common.m delayz.m print_polynomial.m \
bitflip_bandpass_R2_test_common.m flt2SD.m SDadders.m x2nextra.m qroots.oct \
bin2SD.oct bitflip.oct bin2SPT.oct"

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
cat > test.n_ex.ok << 'EOF'
n_ex = [   0.0132437045,   0.0099747219,   0.0151471874,   0.0132682261, ... 
           0.0338011593,   0.0312284990,   0.0222320281,  -0.0048345466, ... 
          -0.0035465728,  -0.0085476933,  -0.0390125715,  -0.0923660893, ... 
          -0.0988713363,  -0.0069058497,   0.1152350957,   0.1714912441, ... 
           0.0917092334,  -0.0279307251,  -0.1059098675,  -0.0844332962, ... 
          -0.0382116440 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.3167759981,   0.0000000000, ... 
           1.5042300040,   0.0000000000,   1.6102725888,   0.0000000000, ... 
           1.5833356107,   0.0000000000,   1.2502597007,   0.0000000000, ... 
           0.9040080640,   0.0000000000,   0.5219589344,   0.0000000000, ... 
           0.2644305194,   0.0000000000,   0.0946630825,   0.0000000000, ... 
           0.0266181240 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_ex.ok"; fail; fi

cat > test.n_rd.ok << 'EOF'
n_rd = [        2,        1,        2,        2, ... 
                4,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -13,       -1,       15,       22, ... 
               12,       -4,      -14,      -11, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_rd.ok"; fail; fi

cat > test.d_rd.ok << 'EOF'
d_rd = [      128,        0,      168,        0, ... 
              192,        0,      206,        0, ... 
              202,        0,      160,        0, ... 
              116,        0,       67,        0, ... 
               34,        0,       12,        0, ... 
                3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_rd.ok"; fail; fi

cat > test.n_bf.ok << 'EOF'
n_bf = [        2,        2,        2,        2, ... 
                4,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -13,       -1,       15,       22, ... 
               11,       -4,      -14,      -11, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi

cat > test.d_bf.ok << 'EOF'
d_bf = [      136,        0,      176,        0, ... 
              196,        0,      206,        0, ... 
              202,        0,      160,        0, ... 
              117,        0,       67,        0, ... 
               34,        0,       12,        0, ... 
                3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bf.ok"; fail; fi

cat > test.n_sd.ok << 'EOF'
n_sd = [        2,        1,        2,        2, ... 
                4,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -12,       -1,       15,       24, ... 
               12,       -4,      -14,      -12, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_sd.ok"; fail; fi

cat > test.d_sd.ok << 'EOF'
d_sd = [      128,        0,      160,        0, ... 
              192,        0,      192,        0, ... 
              192,        0,      160,        0, ... 
              112,        0,       68,        0, ... 
               34,        0,       12,        0, ... 
                3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_sd.ok"; fail; fi

cat > test.n_bfsd.ok << 'EOF'
n_bfsd = [        2,        2,        2,        2, ... 
                  2,        1,        0,       -1, ... 
                  1,       -1,       -5,      -12, ... 
                -12,       -1,       14,       20, ... 
                 12,       -4,      -14,      -12, ... 
                 -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi

cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [      144,        0,      160,        0, ... 
                192,        0,      192,        0, ... 
                192,        0,      160,        0, ... 
                120,        0,       68,        0, ... 
                 36,        0,       12,        0, ... 
                  4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_directIIR_bandpass_R2_test"

diff -Bb test.n_ex.ok $nstr"_n_ex_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_ex.ok"; fail; fi

diff -Bb test.d_ex.ok $nstr"_d_ex_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_ex.ok"; fail; fi

diff -Bb test.n_rd.ok $nstr"_n_rd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_rd.ok"; fail; fi

diff -Bb test.d_rd.ok $nstr"_d_rd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_rd.ok"; fail; fi

diff -Bb test.n_bf.ok $nstr"_n_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bf.ok"; fail; fi

diff -Bb test.d_bf.ok $nstr"_d_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bf.ok"; fail; fi

diff -Bb test.n_sd.ok $nstr"_n_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_sd.ok"; fail; fi

diff -Bb test.d_sd.ok $nstr"_d_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_sd.ok"; fail; fi

diff -Bb test.n_bfsd.ok $nstr"_n_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bfsd.ok"; fail; fi

diff -Bb test.d_bfsd.ok $nstr"_d_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bfsd.ok"; fail; fi

#
# this much worked
#
pass

