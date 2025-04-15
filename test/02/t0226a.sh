#!/bin/sh

prog=bitflip_schurNSlattice_bandpass_R2_test.m

depends="test/bitflip_schurNSlattice_bandpass_R2_test.m \
../iir_sqp_slb_bandpass_R2_test_D1_coef.m \
../iir_sqp_slb_bandpass_R2_test_N1_coef.m \
test_common.m delayz.m bitflip_bandpass_R2_test_common.m schurNSlattice2tf.m SDadders.m \
schurNSlattice_cost.m schurNSscale.oct schurdecomp.oct schurexpand.oct \
schurNSlattice2Abcd.oct Abcd2tf.m tf2schurNSlattice.m bin2SD.oct flt2SD.m \
x2nextra.m bitflip.oct print_polynomial.m bin2SPT.oct"
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
cat > test.s10_bfsd.ok << 'EOF'
s10_bfsd = [     -112,     -120,      -80,       -2, ... 
                   72,       72,       28,      -15, ... 
                  -24,       -7,        1,       -6, ... 
                  -10,       -4,        4,        4, ... 
                    0,       -1,        2,        2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11_bfsd.ok << 'EOF'
s11_bfsd = [       56,       48,       96,      128, ... 
                   96,      120,      127,      127, ... 
                  127,      130,      132,      128, ... 
                  128,      128,      128,      128, ... 
                  128,      128,      128,       68 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20_bfsd.ok << 'EOF'
s20_bfsd = [        0,       64,        0,       31, ... 
                    0,       24,        0,       34, ... 
                    0,       60,        0,       32, ... 
                    0,       32,        0,       63, ... 
                    0,       63,        0,        4 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00_bfsd.ok << 'EOF'
s00_bfsd = [      128,      112,      128,      120, ... 
                  128,      120,      128,      112, ... 
                  128,      120,      128,      112, ... 
                  128,      127,      128,      127, ... 
                  128,      128,      128,      128 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02_bfsd.ok << 'EOF'
s02_bfsd = [        0,      -72,        0,      -48, ... 
                    0,      -36,        0,      -56, ... 
                    0,      -40,        0,      -40, ... 
                    0,      -28,        0,      -20, ... 
                    0,       -8,        0,       -4 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22_bfsd.ok << 'EOF'
s22_bfsd = [      128,       96,      128,      126, ... 
                  128,      120,      128,      112, ... 
                  128,      127,      128,      120, ... 
                  128,      127,      128,      127, ... 
                  128,      128,      128,      128 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi

cat > test.bfsd_adders.ok << 'EOF'
$52$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.bfsd_adders.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact & 1.4838 \\ 
8-bit rounded & 1.6404 \\ 
8-bit rounded with bitflipping & 1.0149 \\ 
8-bit 2-signed-digit & 2.8931 \\ 
8-bit 2-signed-digit with bitflipping & 1.4418 \\ 
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="bitflip_schurNSlattice_bandpass_R2_test"

diff -Bb test.s10_bfsd.ok $nstr"_s10_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10_bfsd.ok"; fail; fi

diff -Bb test.s11_bfsd.ok $nstr"_s11_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11_bfsd.ok"; fail; fi

diff -Bb test.s20_bfsd.ok $nstr"_s20_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20_bfsd.ok"; fail; fi

diff -Bb test.s00_bfsd.ok $nstr"_s00_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02_bfsd.ok"; fail; fi

diff -Bb test.s02_bfsd.ok $nstr"_s02_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00_bfsd.ok"; fail; fi

diff -Bb test.s22_bfsd.ok $nstr"_s22_bfsd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22_bfsd.ok"; fail; fi

diff -Bb test.bfsd_adders.ok $nstr"_adders.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.bfsd_adders.ok"; fail; fi

diff -Bb test.cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.cost.ok"; fail; fi

#
# this much worked
#
pass

