#!/bin/sh

prog=bitflip_svcasc_test.m

depends="bitflip_svcasc_test.m test_common.m truncation_test_common.m \
sos2pq.m pq2svcasc.m svcasc2tf.m svcasc_cost.m bin2SD.oct flt2SD.m \
x2nextra.m bitflip.oct print_polynomial.m"

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
cost_rd= 1.23622
cost_bf= 0.99291
cost_sd=     Inf
cost_bfsd= 1.13336
a11_rd = [   0.6875000000,   0.6875000000,   0.0000000000 ];
a12_rd = [  -0.6875000000,  -0.4062500000,   1.0000000000 ];
a21_rd = [   0.6875000000,   0.5625000000,   0.0000000000 ];
a22_rd = [   0.6875000000,   0.6875000000,   0.7187500000 ];
b1_rd = [   0.3437500000,   0.6875000000,   0.0000000000 ];
b2_rd = [   0.1250000000,   0.0937500000,   1.0000000000 ];
c1_rd = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_rd = [   0.8125000000,   0.3437500000,   0.4687500000 ];
dd_rd = [   0.2812500000,   0.2812500000,   0.2812500000 ];
a11_bf = [   0.6875000000,   0.7500000000,   0.0000000000 ];
a12_bf = [  -0.6875000000,  -0.4062500000,   1.0000000000 ];
a21_bf = [   0.6875000000,   0.5625000000,   0.0000000000 ];
a22_bf = [   0.6875000000,   0.6875000000,   0.7187500000 ];
b1_bf = [   0.3437500000,   0.6875000000,   0.0000000000 ];
b2_bf = [   0.0625000000,   0.0937500000,   1.0000000000 ];
c1_bf = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_bf = [   0.8125000000,   0.3437500000,   0.4687500000 ];
dd_bf = [   0.2812500000,   0.2812500000,   0.2812500000 ];
a11_bfsd = [   0.5625000000,   0.6250000000,   0.0000000000 ];
a12_bfsd = [  -0.7500000000,  -0.3750000000,   1.0000000000 ];
a21_bfsd = [   0.5625000000,   0.6250000000,   0.0000000000 ];
a22_bfsd = [   0.7500000000,   0.6250000000,   0.7500000000 ];
b1_bfsd = [   0.4375000000,   0.7500000000,   0.0000000000 ];
b2_bfsd = [   0.1562500000,   0.0937500000,   1.0000000000 ];
c1_bfsd = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_bfsd = [   0.7500000000,   0.3750000000,   0.4687500000 ];
dd_bfsd = [   0.1562500000,   0.3125000000,   0.3125000000 ];
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

