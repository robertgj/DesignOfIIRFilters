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
k_ex = [   0.7029397495,   0.2279826972,  -0.3955567423,  -0.5882455490, ... 
          -0.4532559631,   0.0080174573,   0.4231213590,   0.4912837385, ... 
           0.2373642214,  -0.2331586460,  -0.5588886861,  -0.7324700649, ... 
          -0.8699862154,   0.6534907148,  -0.5512846248,   0.1703801117 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [       90,       29,      -51,      -75, ... 
              -58,        1,       54,       63, ... 
               30,      -30,      -72,      -94, ... 
             -111,       84,      -71,       22 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [       85,       29,      -51,      -75, ... 
              -58,        2,       63,       63, ... 
               45,      -30,      -72,      -94, ... 
             -111,       85,      -71,       24 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [       96,       28,      -48,      -72, ... 
              -56,        1,       56,       63, ... 
               30,      -30,      -72,      -96, ... 
             -112,       80,      -72,       24 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [       80,       36,      -48,      -72, ... 
                -56,       12,       63,       63, ... 
                 56,      -30,      -72,      -96, ... 
               -112,       80,      -72,       18 ]/128;
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

