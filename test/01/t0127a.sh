#!/bin/sh

prog=bitflip_schurNSPAlattice_lowpass_test.m

depends="bitflip_schurNSPAlattice_lowpass_test.m test_common.m print_polynomial.m \
truncation_test_common.m schurNSPAlattice2tf.m schurNSPAlattice_cost.m \
tf2schurNSlattice.m Abcd2tf.m flt2SD.m x2nextra.m  tf2pa.m \
bitflip.oct spectralfactor.oct schurNSscale.oct schurdecomp.oct \
schurexpand.oct bin2SD.oct schurNSlattice2Abcd.oct"

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
cost_rd= 1.24590
cost_bf= 0.98608
cost_sd= 3.60587
cost_bfsd= 1.38244
A1s20_bf = [  -0.8125000000,   0.7187500000 ]';
A1s00_bf = [   0.5625000000,   0.7187500000 ]';
A1s02_bf = [   0.8125000000,  -0.7187500000 ]';
A1s22_bf = [   0.5625000000,   0.7187500000 ]';
A2s20_bf = [  -0.7500000000,   0.9375000000,  -0.6875000000 ]';
A2s00_bf = [   0.6562500000,   0.3437500000,   0.7500000000 ]';
A2s02_bf = [   0.7500000000,  -0.9375000000,   0.6875000000 ]';
A2s22_bf = [   0.6562500000,   0.3437500000,   0.7500000000 ]';
A1s20_bfsd = [  -0.7500000000,   0.7500000000 ]';
A1s00_bfsd = [   0.5312500000,   0.7500000000 ]';
A1s02_bfsd = [   0.8750000000,  -0.7500000000 ]';
A1s22_bfsd = [   0.5625000000,   0.7500000000 ]';
A2s20_bfsd = [  -0.7500000000,   0.8750000000,  -0.7500000000 ]';
A2s00_bfsd = [   0.6250000000,   0.4375000000,   0.7500000000 ]';
A2s02_bfsd = [   0.7500000000,  -0.9375000000,   0.7500000000 ]';
A2s22_bfsd = [   0.6250000000,   0.3750000000,   0.7500000000 ]';
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

