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
n_ex = [   0.0121797025,   0.0037181466,   0.0271208444,   0.0229180899, ... 
           0.0527427390,   0.0310257396,   0.0310148929,  -0.0050816528, ... 
          -0.0052190028,  -0.0414041061,  -0.0726994834,  -0.0996450244, ... 
          -0.0564833866,   0.0506036935,   0.1386006506,   0.1492761564, ... 
           0.0507378434,  -0.0443572576,  -0.1001730674,  -0.0681538294, ... 
          -0.0335038915 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_ex.ok"; fail; fi
cat > test.d_ex.ok << 'EOF'
d_ex = [   1.0000000000,   0.0000000000,   1.8567605231,   0.0000000000, ... 
           2.1933886439,   0.0000000000,   2.2557980857,   0.0000000000, ... 
           2.0335494061,   0.0000000000,   1.5306996820,   0.0000000000, ... 
           0.9936532921,   0.0000000000,   0.5470027574,   0.0000000000, ... 
           0.2511015052,   0.0000000000,   0.0839735161,   0.0000000000, ... 
           0.0183734564 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_ex.ok"; fail; fi
cat > test.n_rd.ok << 'EOF'
n_rd = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125, -0.00000, ... 
         -0.00000, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.06250,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_rd.ok"; fail; fi
cat > test.d_rd.ok << 'EOF'
d_rd = [  1.00000,  0.00000,  1.87500,  0.00000, ... 
          2.25000,  0.00000,  2.25000,  0.00000, ... 
          2.00000,  0.00000,  1.50000,  0.00000, ... 
          1.00000,  0.00000,  0.56250,  0.00000, ... 
          0.25000,  0.00000,  0.09375,  0.00000, ... 
          0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_rd.ok"; fail; fi
cat > test.n_bf.ok << 'EOF'
n_bf = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125, -0.00000, ... 
         -0.00000, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.06250,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bf.ok"; fail; fi
cat > test.d_bf.ok << 'EOF'
d_bf = [  1.37500,  0.03125,  1.93750,  0.06250, ... 
          2.25000,  0.00000,  2.25000,  0.06250, ... 
          2.00000,  0.06250,  1.50000,  0.00000, ... 
          1.00000,  0.00000,  0.56250,  0.00000, ... 
          0.28125,  0.00000,  0.09375,  0.00000, ... 
          0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_bf.ok"; fail; fi
cat > test.n_sd.ok << 'EOF'
n_sd = [ -0.00000, -0.00000,  0.03125,  0.03125, ... 
          0.06250,  0.03125,  0.03125,  0.00000, ... 
          0.00000, -0.03125, -0.06250, -0.09375, ... 
         -0.06250,  0.06250,  0.12500,  0.15625, ... 
          0.06250, -0.03125, -0.09375, -0.06250, ... 
         -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_sd.ok"; fail; fi
cat > test.d_sd.ok << 'EOF'
d_sd = [  1.00000,  0.00000,  1.87500,  0.00000, ... 
          2.25000,  0.00000,  2.25000,  0.00000, ... 
          2.00000,  0.00000,  1.50000,  0.00000, ... 
          1.00000,  0.00000,  0.56250,  0.00000, ... 
          0.25000,  0.00000,  0.09375,  0.00000, ... 
          0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d_sd.ok"; fail; fi
cat > test.n_bfsd.ok << 'EOF'
n_bfsd = [  0.00000,  0.00000,  0.03125,  0.03125, ... 
            0.06250,  0.03125,  0.03125,  0.00000, ... 
            0.00000, -0.03125, -0.06250, -0.09375, ... 
           -0.06250,  0.06250,  0.12500,  0.15625, ... 
            0.06250, -0.03125, -0.09375, -0.06250, ... 
           -0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.n_bfsd.ok"; fail; fi
cat > test.d_bfsd.ok << 'EOF'
d_bfsd = [  1.37500,  0.03125,  1.93750,  0.06250, ... 
            2.25000,  0.00000,  2.25000,  0.06250, ... 
            2.00000,  0.06250,  1.50000,  0.00000, ... 
            1.00000,  0.00000,  0.56250,  0.00000, ... 
            0.28125,  0.00000,  0.09375,  0.00000, ... 
            0.03125 ];
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

