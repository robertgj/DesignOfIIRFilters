#!/bin/sh

prog=simplex_NS_lattice_test.m

depends="simplex_NS_lattice_test.m test_common.m truncation_test_common.m \
schurNSlattice2tf.m schurNSlattice_cost.m flt2SD.m x2nextra.m \
print_polynomial.m Abcd2tf.m tf2schurNSlattice.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct schurNSlattice2Abcd.oct \
bin2SD.oct"

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
cat > test.ok << 'EOF'
norder =    5.0000e+00
dBpass =    1.0000e+00
dBstop =    4.0000e+01
fpass =    1.2500e-01
fstop =    1.5000e-01
nbits =    6.0000e+00
ndigits =    2.0000e+00
bitstart =    4.0000e+00
msize =    3.0000e+00
cost_ex= 1.00080
cost_rd= 1.54321
cost_sx= 1.03974
cost_sd= 2.33728
cost_sxsd= 1.65813
s10_rd = [   0.9687500000,   0.6875000000,   0.3437500000,   0.1250000000, ... 
             0.0312500000 ]';
s11_rd = [   0.2187500000,   0.7187500000,   0.9375000000,   1.0000000000, ... 
             0.4687500000 ]';
s20_rd = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
            -0.4687500000 ]';
s00_rd = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s02_rd = [   0.7812500000,  -0.9687500000,   0.8750000000,  -0.8125000000, ... 
             0.4687500000 ]';
s22_rd = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s10_sx = [   0.9687500000,   0.6875000000,   0.3437500000,   0.1562500000, ... 
             0.0312500000 ]';
s11_sx = [   0.2187500000,   0.7187500000,   0.9375000000,   1.0000000000, ... 
             0.5000000000 ]';
s20_sx = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
            -0.4687500000 ]';
s00_sx = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s02_sx = [   0.7812500000,  -0.9687500000,   0.8750000000,  -0.8125000000, ... 
             0.4687500000 ]';
s22_sx = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s10_sd = [   0.9687500000,   0.7500000000,   0.3750000000,   0.1250000000, ... 
             0.0312500000 ]';
s11_sd = [   0.2187500000,   0.7500000000,   0.9375000000,   1.0000000000, ... 
             0.4687500000 ]';
s20_sd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
            -0.4687500000 ]';
s00_sd = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s02_sd = [   0.7500000000,  -0.9687500000,   0.8750000000,  -0.7500000000, ... 
             0.4687500000 ]';
s22_sd = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
             0.8750000000 ]';
s10_sxsd = [   0.9687500000,   0.7500000000,   0.3750000000,   0.1250000000, ... 
               0.0312500000 ]';
s11_sxsd = [   0.2187500000,   0.7500000000,   0.9375000000,   1.0000000000, ... 
               0.5000000000 ]';
s20_sxsd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
              -0.4687500000 ]';
s00_sxsd = [   0.6250000000,   0.2812500000,   0.5000000000,   0.5625000000, ... 
               0.8750000000 ]';
s02_sxsd = [   0.7500000000,  -0.9687500000,   0.8750000000,  -0.7500000000, ... 
               0.4687500000 ]';
s22_sxsd = [   0.6250000000,   0.2812500000,   0.4687500000,   0.5625000000, ... 
               0.8750000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

