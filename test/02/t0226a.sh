#!/bin/sh

prog=bitflip_bandpass_NS_lattice_test.m

depends="bitflip_bandpass_NS_lattice_test.m test_common.m \
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
s10_bfsd = [  0.18750, -0.84375, -0.84375, -0.53125, ... 
              0.21875,  0.56250,  0.43750,  0.09375, ... 
             -0.12500, -0.09375,  0.00000, -0.03125, ... 
             -0.09375, -0.06250,  0.00000,  0.03125, ... 
              0.03125,  0.00000,  0.00000,  0.00000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11_bfsd.ok << 'EOF'
s11_bfsd = [  1.00000,  0.50000,  0.53125,  0.87500, ... 
              0.96875,  0.84375,  0.90625,  1.00000, ... 
              1.00000,  1.00000,  1.00000,  1.00000, ... 
              1.00000,  1.00000,  1.00000,  1.00000, ... 
              1.00000,  1.00000,  1.00000,  0.50000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20_bfsd.ok << 'EOF'
s20_bfsd = [  0.00000,  0.50000,  0.00000,  0.50000, ... 
              0.00000,  0.34375,  0.00000,  0.37500, ... 
              0.00000,  0.25000,  0.00000,  0.46875, ... 
              0.00000,  0.00000,  0.00000,  0.00000, ... 
              0.00000,  0.03125,  0.00000,  0.00000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00_bfsd.ok << 'EOF'
s00_bfsd = [  1.00000,  0.75000,  1.00000,  0.87500, ... 
              1.00000,  0.93750,  1.00000,  0.90625, ... 
              1.00000,  0.90625,  1.00000,  0.96875, ... 
              1.00000,  1.00000,  1.00000,  1.00000, ... 
              1.00000,  1.00000,  1.00000,  1.00000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02_bfsd.ok << 'EOF'
s02_bfsd = [  0.00000, -0.75000,  0.00000, -0.50000, ... 
              0.00000, -0.37500,  0.00000, -0.40625, ... 
              0.00000, -0.31250,  0.00000, -0.25000, ... 
              0.00000, -0.15625,  0.00000, -0.09375, ... 
              0.00000, -0.03125,  0.00000,  0.00000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22_bfsd.ok << 'EOF'
s22_bfsd = [  1.00000,  0.62500,  1.00000,  0.84375, ... 
              1.00000,  0.96875,  1.00000,  0.90625, ... 
              1.00000,  0.84375,  1.00000,  0.96875, ... 
              1.00000,  1.00000,  1.00000,  1.00000, ... 
              1.00000,  1.00000,  1.00000,  1.00000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi

cat > test.sbfsd_adders.ok << 'EOF'
$47$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.sbfsd_adders.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi


diff -Bb test.s10_bfsd.ok bitflip_bandpass_NS_lattice_test_s10_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10_bfsd.ok"; fail; fi

diff -Bb test.s11_bfsd.ok bitflip_bandpass_NS_lattice_test_s11_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11_bfsd.ok"; fail; fi

diff -Bb test.s20_bfsd.ok bitflip_bandpass_NS_lattice_test_s20_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20_bfsd.ok"; fail; fi

diff -Bb test.s00_bfsd.ok bitflip_bandpass_NS_lattice_test_s00_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02_bfsd.ok"; fail; fi

diff -Bb test.s02_bfsd.ok bitflip_bandpass_NS_lattice_test_s02_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00_bfsd.ok"; fail; fi

diff -Bb test.s22_bfsd.ok bitflip_bandpass_NS_lattice_test_s22_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22_bfsd.ok"; fail; fi

diff -Bb test.sbfsd_adders.ok bitflip_bandpass_NS_lattice_test_adders.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.sbfsd_adders.ok"; fail; fi

#
# this much worked
#
pass

