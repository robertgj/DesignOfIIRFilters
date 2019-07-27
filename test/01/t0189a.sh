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
n_ex = [   0.0119656597,   0.0054227177,   0.0227005335,   0.0226922170, ... 
           0.0478437399,   0.0344596061,   0.0300157817,   0.0005327649, ... 
          -0.0020161873,  -0.0307157202,  -0.0676394572,  -0.1024149854, ... 
          -0.0701854751,   0.0360117096,   0.1357490011,   0.1563338602, ... 
           0.0634407938,  -0.0393847506,  -0.0985413186,  -0.0711217507, ... 
          -0.0333908343 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.7101927107,   0.0000000000, ... 
           1.9390379556,   0.0000000000,   1.9462051796,   0.0000000000, ... 
           1.7230562169,   0.0000000000,   1.2665042758,   0.0000000000, ... 
           0.8113877164,   0.0000000000,   0.4380806647,   0.0000000000, ... 
           0.1988495226,   0.0000000000,   0.0656499208,   0.0000000000, ... 
           0.0148050095 ];
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
               -9,        5,       17,       20, ... 
                8,       -5,      -13,       -9, ... 
               -4 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi

cat > test.d_bf.ok << 'EOF'
d_bf = [      130,        0,      220,        1, ... 
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

