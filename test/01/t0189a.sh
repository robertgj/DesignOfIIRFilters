#!/bin/sh

prog=bitflip_bandpass_direct_test.m
depends="bitflip_bandpass_direct_test.m test_common.m print_polynomial.m \
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
n_ex = [   0.0119898572,   0.0055005262,   0.0227465629,   0.0227676952, ... 
           0.0477699159,   0.0346032386,   0.0300158271,   0.0007692638, ... 
          -0.0021264872,  -0.0305118086,  -0.0677680871,  -0.1021835628, ... 
          -0.0704487200,   0.0361830861,   0.1357812748,   0.1570834904, ... 
           0.0638315615,  -0.0390403107,  -0.0989222753,  -0.0714382761, ... 
          -0.0337487587 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi

cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.7122688809,   0.0000000000, ... 
           1.9398016652,   0.0000000000,   1.9464309420,   0.0000000000, ... 
           1.7222723403,   0.0000000000,   1.2656797602,   0.0000000000, ... 
           0.8103366569,   0.0000000000,   0.4372977468,   0.0000000000, ... 
           0.1983164681,   0.0000000000,   0.0654678098,   0.0000000000, ... 
           0.0147305592 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_ex.ok"; fail; fi

cat > test.n_rd.ok << 'EOF'
n_rd = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125,  0.00000, ... 
         -0.00000, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.03125,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_rd.ok"; fail; fi

cat > test.d_rd.ok << 'EOF'
d_rd = [  1.00000,  0.00000,  1.68750,  0.00000, ... 
          1.93750,  0.00000,  1.93750,  0.00000, ... 
          1.75000,  0.00000,  1.25000,  0.00000, ... 
          0.81250,  0.00000,  0.43750,  0.00000, ... 
          0.18750,  0.00000,  0.06250,  0.00000, ... 
          0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_rd.ok"; fail; fi

cat > test.n_bf.ok << 'EOF'
n_bf = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125,  0.00000, ... 
          0.03125, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.03125,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi

cat > test.d_bf.ok << 'EOF'
d_bf = [  1.31250,  0.03125,  1.68750,  0.06250, ... 
          1.93750,  0.06250,  1.93750,  0.00000, ... 
          1.75000,  0.06250,  1.25000,  0.00000, ... 
          0.81250,  0.00000,  0.43750,  0.00000, ... 
          0.18750,  0.00000,  0.06250,  0.00000, ... 
          0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bf.ok"; fail; fi

cat > test.n_sd.ok << 'EOF'
n_sd = [ -0.00000, -0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125, -0.00000, ... 
          0.00000, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.03125,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_sd.ok"; fail; fi

cat > test.d_sd.ok << 'EOF'
d_sd = [  1.00000,  0.00000,  1.68750,  0.00000, ... 
          1.93750,  0.00000,  1.93750,  0.00000, ... 
          1.75000,  0.00000,  1.25000,  0.00000, ... 
          0.81250,  0.00000,  0.43750,  0.00000, ... 
          0.18750,  0.00000,  0.06250,  0.00000, ... 
         -0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_sd.ok"; fail; fi

cat > test.n_bfsd.ok << 'EOF'
n_bfsd = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
            0.06250,  0.03125,  0.03125,  0.00000, ... 
            0.03125, -0.03125, -0.06250, -0.09375, ... 
           -0.06250,  0.03125,  0.12500,  0.15625, ... 
            0.06250, -0.03125, -0.09375, -0.06250, ... 
           -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi

cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [  1.31250,  0.03125,  1.68750,  0.06250, ... 
            1.93750,  0.06250,  1.93750,  0.00000, ... 
            1.75000,  0.06250,  1.25000,  0.00000, ... 
            0.81250,  0.00000,  0.43750,  0.00000, ... 
            0.18750,  0.00000,  0.06250,  0.00000, ... 
            0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.n_ex.ok bitflip_bandpass_direct_test_n_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_ex.ok"; fail; fi
diff -Bb test.d_ex.ok bitflip_bandpass_direct_test_d_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_ex.ok"; fail; fi
diff -Bb test.n_rd.ok bitflip_bandpass_direct_test_n_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_rd.ok"; fail; fi
diff -Bb test.d_rd.ok bitflip_bandpass_direct_test_d_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_rd.ok"; fail; fi
diff -Bb test.n_bf.ok bitflip_bandpass_direct_test_n_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bf.ok"; fail; fi
diff -Bb test.d_bf.ok bitflip_bandpass_direct_test_d_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bf.ok"; fail; fi
diff -Bb test.n_sd.ok bitflip_bandpass_direct_test_n_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_sd.ok"; fail; fi
diff -Bb test.d_sd.ok bitflip_bandpass_direct_test_d_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_sd.ok"; fail; fi
diff -Bb test.n_bfsd.ok bitflip_bandpass_direct_test_n_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.n_bfsd.ok"; fail; fi
diff -Bb test.d_bfsd.ok bitflip_bandpass_direct_test_d_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d_bfsd.ok"; fail; fi

#
# this much worked
#
pass

