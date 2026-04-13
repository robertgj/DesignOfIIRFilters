#!/bin/sh

prog=bitflip_schurFIRlattice_bandpass_test.m
depends="test/bitflip_schurFIRlattice_bandpass_test.m \
../iir_sqp_slb_fir_17_bandpass_test_b1_coef.m \
test_common.m delayz.m bitflip_bandpass_test_common.m flt2SD.m \
schurFIRlattice2Abcd.m Abcd2tf.m print_polynomial.m x2nextra.m SDadders.m \
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
k_ex = [   0.9012916746,   0.8520505738,   0.1739864295,  -0.1697181581, ... 
          -0.6773178124,  -0.4142273428,  -0.0273127688,   0.3363759329, ... 
           0.6439790876,  -0.0386790967,   0.1095138256,  -0.8879223652, ... 
          -0.8728429046,   0.2638283447,   0.0096621067,  -0.2959189610 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [      115,      109,       22,      -22, ... 
              -87,      -53,       -3,       43, ... 
               82,       -5,       14,     -114, ... 
             -112,       34,        1,      -38 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [       71,      103,       22,      -22, ... 
              -87,      -53,       -3,       56, ... 
               89,       -5,       27,     -114, ... 
             -112,        0,       63,      -38 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [      112,      112,       24,      -24, ... 
              -80,      -56,       -3,       40, ... 
               80,       -5,       14,     -112, ... 
             -112,       34,        1,      -40 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [       96,      112,        0,      -24, ... 
                -80,      -56,       -3,       63, ... 
                 80,       -5,       20,     -112, ... 
               -112,       12,       40,      -40 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_schurFIRlattice_bandpass_test"

diff -Bb test.k_ex.ok $nstr"_k_ex_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_ex.ok"; fail; fi

diff -Bb test.k_rd.ok $nstr"_k_rd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi

diff -Bb test.k_bf.ok $nstr"_k_bf_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi

diff -Bb test.k_sd.ok $nstr"_k_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi

diff -Bb test.k_bfsd.ok $nstr"_k_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi

#
# this much worked
#
pass

