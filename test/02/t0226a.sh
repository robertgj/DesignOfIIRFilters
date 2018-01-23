#!/bin/sh

prog=bitflip_schurNSlattice_bandpass_test.m

depends="bitflip_schurNSlattice_bandpass_test.m test_common.m \
bitflip_bandpass_test_common.m schurNSlattice2tf.m SDadders.m \
schurNSlattice_cost.m schurNSscale.oct schurdecomp.oct schurexpand.oct \
schurNSlattice2Abcd.oct Abcd2tf.m tf2schurNSlattice.m bin2SD.oct flt2SD.m \
x2nextra.m bitflip.oct print_polynomial.m bin2SPT.oct"
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
cat > test.s10_bfsd.ok << 'EOF'
s10_bfsd = [    2, -112, -112,  -68, ... 
               24,   72,   56,   10, ... 
              -17,  -12,   -2,   -3, ... 
              -10,   -9,    0,    5, ... 
                4,    1,    1,    2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11_bfsd.ok << 'EOF'
s11_bfsd = [  126,   80,   65,  112, ... 
              124,  112,  112,  128, ... 
              126,  126,  136,  136, ... 
              128,  132,  128,  128, ... 
              128,  128,  128,   56 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20_bfsd.ok << 'EOF'
s20_bfsd = [    0,   96,    0,   60, ... 
                0,   56,    0,   32, ... 
                0,   18,    0,   63, ... 
                0,   20,    0,   15, ... 
                0,   15,    0,    2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00_bfsd.ok << 'EOF'
s00_bfsd = [  128,   72,  128,  112, ... 
              128,  120,  128,  120, ... 
              128,  120,  128,  124, ... 
              128,  124,  128,  127, ... 
              128,  128,  128,  128 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02_bfsd.ok << 'EOF'
s02_bfsd = [    0,  -96,    0,  -63, ... 
                0,  -48,    0,  -48, ... 
                0,  -40,    0,  -33, ... 
                0,  -20,    0,  -12, ... 
                0,   -5,    0,   -2 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22_bfsd.ok << 'EOF'
s22_bfsd = [  128,   68,  128,  112, ... 
              128,  124,  128,  120, ... 
              128,  112,  128,  124, ... 
              128,  127,  128,  127, ... 
              128,  128,  128,  128 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi

cat > test.sbfsd_adders.ok << 'EOF'
$59$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.sbfsd_adders.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


diff -Bb test.s10_bfsd.ok bitflip_schurNSlattice_bandpass_test_s10_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10_bfsd.ok"; fail; fi

diff -Bb test.s11_bfsd.ok bitflip_schurNSlattice_bandpass_test_s11_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11_bfsd.ok"; fail; fi

diff -Bb test.s20_bfsd.ok bitflip_schurNSlattice_bandpass_test_s20_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20_bfsd.ok"; fail; fi

diff -Bb test.s00_bfsd.ok bitflip_schurNSlattice_bandpass_test_s00_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02_bfsd.ok"; fail; fi

diff -Bb test.s02_bfsd.ok bitflip_schurNSlattice_bandpass_test_s02_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00_bfsd.ok"; fail; fi

diff -Bb test.s22_bfsd.ok bitflip_schurNSlattice_bandpass_test_s22_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22_bfsd.ok"; fail; fi

diff -Bb test.sbfsd_adders.ok bitflip_schurNSlattice_bandpass_test_adders.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.sbfsd_adders.ok"; fail; fi

#
# this much worked
#
pass

