#!/bin/sh

prog=bitflip_directIIR_bandpass_test.m
depends="bitflip_directIIR_bandpass_test.m test_common.m print_polynomial.m \
bitflip_bandpass_test_common.m flt2SD.m SDadders.m x2nextra.m \
bin2SD.oct bitflip.oct bin2SPT.oct"

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
cat > test.n_ex.ok << 'EOF'
n_ex = [   0.0119791719,   0.0055196153,   0.0227331458,   0.0227914190, ... 
           0.0478041828,   0.0346917424,   0.0301303014,   0.0008781758, ... 
          -0.0019950672,  -0.0304170074,  -0.0676696158,  -0.1022691500, ... 
          -0.0706575011,   0.0358390487,   0.1355863349,   0.1570889466, ... 
           0.0640606014,  -0.0387898868,  -0.0987542367,  -0.0713801047, ... 
          -0.0337535000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.7123000538,   0.0000000000, ... 
           1.9402922218,   0.0000000000,   1.9473017989,   0.0000000000, ... 
           1.7233349664,   0.0000000000,   1.2666849197,   0.0000000000, ... 
           0.8111419473,   0.0000000000,   0.4378142096,   0.0000000000, ... 
           0.1985844837,   0.0000000000,   0.0655700341,   0.0000000000, ... 
           0.0147544552 ];
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
d_rd = [      128,        0,      220,        0, ... 
              248,        0,      250,        0, ... 
              220,        0,      162,        0, ... 
              104,        0,       56,        0, ... 
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
d_bf = [      132,        1,      220,        2, ... 
              248,        0,      250,        0, ... 
              220,        0,      162,        0, ... 
              104,        0,       56,        0, ... 
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
n_bfsd = [        2,        1,        3,        4, ... 
                  6,        4,        4,        0, ... 
                  0,       -4,       -9,      -12, ... 
                 -9,        5,       17,       20, ... 
                  8,       -5,      -12,       -9, ... 
                 -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi

cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [      192,        0,      240,       20, ... 
                248,       16,      248,        9, ... 
                224,        0,      160,        8, ... 
                 96,        4,       56,        0, ... 
                 24,        2,        8,        0, ... 
                  2 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog > test.out
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

