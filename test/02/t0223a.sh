#!/bin/sh

prog=bitflip_schurFIRlattice_bandpass_test.m
depends="bitflip_schurFIRlattice_bandpass_test.m \
../iir_sqp_slb_bandpass_test_D1_coef.m \
../iir_sqp_slb_bandpass_test_N1_coef.m \
test_common.m \
../iir_sqp_slb_fir_17_bandpass_test_b1_coef.m \
bitflip_bandpass_test_common.m flt2SD.m schurFIRlattice2Abcd.m \
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
k_ex = [   0.4615008866,   0.0225064781,  -0.4542078180,  -0.5741065156, ... 
          -0.3672496609,   0.1504824893,   0.4883066788,   0.4462279211, ... 
           0.0648300675,  -0.3812583820,  -0.5965156714,  -0.7277003069, ... 
          -0.8099988670,   0.6810932991,  -0.6079164332,   0.2516530262 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [       59,        3,      -58,      -73, ... 
              -47,       19,       63,       57, ... 
                8,      -49,      -76,      -93, ... 
             -104,       87,      -78,       32 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [       63,       10,      -58,      -73, ... 
              -47,       32,       63,       63, ... 
               32,      -49,      -76,      -93, ... 
             -104,       79,      -78,       19 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [       60,        3,      -56,      -72, ... 
              -48,       20,       63,       56, ... 
                8,      -48,      -80,      -96, ... 
              -96,       80,      -80,       32 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [       60,       10,      -56,      -72, ... 
                -48,       33,       63,       63, ... 
                 32,      -48,      -80,      -96, ... 
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

