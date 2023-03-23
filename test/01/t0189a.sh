#!/bin/sh

prog=bitflip_directIIR_bandpass_test.m
depends="test/bitflip_directIIR_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
test_common.m print_polynomial.m \
bitflip_bandpass_test_common.m flt2SD.m SDadders.m x2nextra.m \
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
n_ex = [   0.0119805617,   0.0053349378,   0.0226038750,   0.0226031114, ... 
           0.0476636685,   0.0341296484,   0.0294623564,   0.0000281382, ... 
          -0.0024749055,  -0.0311018435,  -0.0679743231,  -0.1023390223, ... 
          -0.0694347354,   0.0369913403,   0.1362736102,   0.1556855404, ... 
           0.0622315091,  -0.0405691583,  -0.0988511454,  -0.0711009679, ... 
          -0.0331225232 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.7062464744,   0.0000000000, ... 
           1.9331974063,   0.0000000000,   1.9383131644,   0.0000000000, ... 
           1.7150589700,   0.0000000000,   1.2590545233,   0.0000000000, ... 
           0.8058630835,   0.0000000000,   0.4345272663,   0.0000000000, ... 
           0.1969880077,   0.0000000000,   0.0648455291,   0.0000000000, ... 
           0.0145884545 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_ex.ok"; fail; fi

cat > test.n_rd.ok << 'EOF'
n_rd = [        2,        1,        3,        3, ... 
                6,        4,        4,        0, ... 
                0,       -4,       -9,      -13, ... 
               -9,        5,       17,       20, ... 
                8,       -5,      -13,       -9, ... 
               -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_rd.ok"; fail; fi

cat > test.d_rd.ok << 'EOF'
d_rd = [      128,        0,      218,        0, ... 
              248,        0,      248,        0, ... 
              220,        0,      162,        0, ... 
              103,        0,       56,        0, ... 
               25,        0,        8,        0, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_rd.ok"; fail; fi

cat > test.n_bf.ok << 'EOF'
n_bf = [        2,        1,        3,        3, ... 
                6,        4,        4,        0, ... 
                0,       -4,       -9,      -13, ... 
               -9,        5,       18,       21, ... 
                8,       -5,      -13,       -9, ... 
               -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi
cat > test.d_bf.ok << 'EOF'
d_bf = [      132,        3,      218,        0, ... 
              248,        0,      248,        0, ... 
              220,        0,      162,        0, ... 
              105,        0,       56,        0, ... 
               25,        0,        8,        0, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bf.ok"; fail; fi

cat > test.n_sd.ok << 'EOF'
n_sd = [        2,        1,        3,        3, ... 
                6,        4,        4,        0, ... 
                0,       -4,       -9,      -12, ... 
               -9,        5,       17,       20, ... 
                8,       -5,      -12,       -9, ... 
               -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_sd.ok"; fail; fi

cat > test.d_sd.ok << 'EOF'
d_sd = [      128,        0,      224,        0, ... 
              248,        0,      248,        0, ... 
              224,        0,      160,        0, ... 
               96,        0,       56,        0, ... 
               24,        0,        8,        0, ... 
                2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_sd.ok"; fail; fi

cat > test.n_bfsd.ok << 'EOF'
n_bfsd = [        2,        1,        3,        3, ... 
                  6,        4,        4,        0, ... 
                  0,       -4,       -9,      -12, ... 
                 -9,        5,       17,       20, ... 
                  8,       -5,      -12,       -9, ... 
                 -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi

cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [      160,        2,      240,        9, ... 
                248,       16,      248,        4, ... 
                224,        0,      160,        6, ... 
                 96,        5,       56,        0, ... 
                 24,        3,        8,        0, ... 
                  2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.n_ex.ok bitflip_directIIR_bandpass_test_n_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_ex.ok"; fail; fi

diff -Bb test.d_ex.ok bitflip_directIIR_bandpass_test_d_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_ex.ok"; fail; fi

diff -Bb test.n_rd.ok bitflip_directIIR_bandpass_test_n_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_rd.ok"; fail; fi

diff -Bb test.d_rd.ok bitflip_directIIR_bandpass_test_d_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_rd.ok"; fail; fi

diff -Bb test.n_bf.ok bitflip_directIIR_bandpass_test_n_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bf.ok"; fail; fi

diff -Bb test.d_bf.ok bitflip_directIIR_bandpass_test_d_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bf.ok"; fail; fi

diff -Bb test.n_sd.ok bitflip_directIIR_bandpass_test_n_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_sd.ok"; fail; fi

diff -Bb test.d_sd.ok bitflip_directIIR_bandpass_test_d_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_sd.ok"; fail; fi

diff -Bb test.n_bfsd.ok bitflip_directIIR_bandpass_test_n_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bfsd.ok"; fail; fi

diff -Bb test.d_bfsd.ok bitflip_directIIR_bandpass_test_d_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bfsd.ok"; fail; fi

#
# this much worked
#
pass

