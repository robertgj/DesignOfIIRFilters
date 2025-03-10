#!/bin/sh

prog=bitflip_directIIR_bandpass_test.m
depends="test/bitflip_directIIR_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
test_common.m delayz.m print_polynomial.m \
bitflip_bandpass_test_common.m flt2SD.m SDadders.m x2nextra.m qroots.oct \
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
n_ex = [   0.0134647981,   0.0093004749,   0.0152707492,   0.0131542601, ... 
           0.0343778467,   0.0309994584,   0.0230693329,  -0.0039462668, ... 
          -0.0020928898,  -0.0077387408,  -0.0384148526,  -0.0917402027, ... 
          -0.0993293254,  -0.0079764270,   0.1126065389,   0.1704330531, ... 
           0.0912920938,  -0.0265169717,  -0.1061551592,  -0.0850334100, ... 
          -0.0397898161 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.3256635986,   0.0000000000, ... 
           1.5192420671,   0.0000000000,   1.6305448996,   0.0000000000, ... 
           1.6074037683,   0.0000000000,   1.2729263064,   0.0000000000, ... 
           0.9223931613,   0.0000000000,   0.5341167488,   0.0000000000, ... 
           0.2710986450,   0.0000000000,   0.0971371622,   0.0000000000, ... 
           0.0274736202 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_ex.ok"; fail; fi

cat > test.n_rd.ok << 'EOF'
n_rd = [        2,        1,        2,        2, ... 
                4,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -13,       -1,       14,       22, ... 
               12,       -3,      -14,      -11, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_rd.ok"; fail; fi

cat > test.d_rd.ok << 'EOF'
d_rd = [      128,        0,      170,        0, ... 
              194,        0,      208,        0, ... 
              206,        0,      162,        0, ... 
              118,        0,       68,        0, ... 
               35,        0,       12,        0, ... 
                4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_rd.ok"; fail; fi

cat > test.n_bf.ok << 'EOF'
n_bf = [        2,        1,        2,        2, ... 
                5,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -13,       -1,       14,       22, ... 
               12,       -3,      -14,      -11, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi

cat > test.d_bf.ok << 'EOF'
d_bf = [      138,        1,      170,        4, ... 
              194,        0,      208,        0, ... 
              206,        0,      162,        0, ... 
              118,        0,       68,        0, ... 
               35,        0,       12,        0, ... 
                4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bf.ok"; fail; fi

cat > test.n_sd.ok << 'EOF'
n_sd = [        2,        1,        2,        2, ... 
                4,        4,        3,       -1, ... 
                0,       -1,       -5,      -12, ... 
              -12,       -1,       14,       24, ... 
               12,       -3,      -14,      -12, ... 
               -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_sd.ok"; fail; fi

cat > test.d_sd.ok << 'EOF'
d_sd = [      128,        0,      160,        0, ... 
              192,        0,      192,        0, ... 
              192,        0,      160,        0, ... 
              120,        0,       68,        0, ... 
               36,        0,       12,        0, ... 
                4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_sd.ok"; fail; fi

cat > test.n_bfsd.ok << 'EOF'
n_bfsd = [        1,        0,        0,        2, ... 
                  3,        4,        2,       -1, ... 
                  0,       -1,       -5,      -12, ... 
                -12,       -1,       15,       24, ... 
                 14,       -3,      -14,      -12, ... 
                 -5 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi

cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [      160,        0,      192,       12, ... 
                192,       15,      192,       20, ... 
                192,        2,      160,        0, ... 
                112,        1,       68,        0, ... 
                 36,        0,       12,        1, ... 
                  3 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_directIIR_bandpass_test"

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

