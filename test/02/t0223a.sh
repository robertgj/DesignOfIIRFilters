#!/bin/sh

prog=bitflip_schurFIRlattice_bandpass_test.m
depends="bitflip_schurFIRlattice_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
../iir_sqp_slb_fir_17_bandpass_test_b1_coef.m \
test_common.m bitflip_bandpass_test_common.m flt2SD.m schurFIRlattice2Abcd.m \
Abcd2tf.m print_polynomial.m x2nextra.m SDadders.m \
bin2SPT.oct bin2SD.oct schurFIRdecomp.oct bitflip.oct"

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
cat > test.k_ex.ok << 'EOF'
k_ex = [   0.4673548523,   0.0215846872,  -0.4485631407,  -0.5735447576, ... 
          -0.3680742834,   0.1477578747,   0.4893876472,   0.4478270228, ... 
           0.0701156912,  -0.3783422054,  -0.5960490321,  -0.7267672416, ... 
          -0.7928968758,   0.6674446338,  -0.6400144940,   0.2659821377 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [       60,        3,      -57,      -73, ... 
              -47,       19,       63,       57, ... 
                9,      -48,      -76,      -93, ... 
             -101,       85,      -82,       34 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [       62,       11,      -57,      -73, ... 
              -47,       32,       63,       63, ... 
               32,      -48,      -76,      -93, ... 
             -101,       79,      -82,       22 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [       60,        3,      -56,      -72, ... 
              -48,       20,       63,       56, ... 
                9,      -48,      -80,      -96, ... 
              -96,       80,      -80,       34 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [       56,        9,      -56,      -72, ... 
                -48,       34,       63,       60, ... 
                 28,      -48,      -80,      -96, ... 
                -96,       80,      -80,       24 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k_ex.ok bitflip_schurFIRlattice_bandpass_test_k_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_ex.ok"; fail; fi
diff -Bb test.k_rd.ok bitflip_schurFIRlattice_bandpass_test_k_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi
diff -Bb test.k_bf.ok bitflip_schurFIRlattice_bandpass_test_k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi
diff -Bb test.k_sd.ok bitflip_schurFIRlattice_bandpass_test_k_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi
diff -Bb test.k_bfsd.ok bitflip_schurFIRlattice_bandpass_test_k_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi

#
# this much worked
#
pass

