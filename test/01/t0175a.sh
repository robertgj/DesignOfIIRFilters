#!/bin/sh

prog=simplex_svcasc_lowpass_test.m

depends="simplex_svcasc_lowpass_test.m test_common.m truncation_test_common.m \
sos2pq.m pq2svcasc.m svcasc_cost.m svcasc2tf.m flt2SD.m x2nextra.m bin2SD.oct \
print_polynomial.m qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
norder = 5
dBpass = 1
dBstop = 40
fpass = 0.1250
fstop = 0.1500
nbits = 6
ndigits = 2
bitstart = 4
msize = 3
cost_ex= 1.00080
cost_rd= 1.23622
cost_sx= 0.83949
cost_sd=     Inf
cost_sxsd= 3.21341
a11_rd = [   0.6875000000,   0.6875000000,   0.0000000000 ];
a12_rd = [  -0.6875000000,  -0.4062500000,   1.0000000000 ];
a21_rd = [   0.6875000000,   0.5625000000,   0.0000000000 ];
a22_rd = [   0.6875000000,   0.6875000000,   0.7187500000 ];
b1_rd = [   0.3437500000,   0.6875000000,   0.0000000000 ];
b2_rd = [   0.1250000000,   0.0937500000,   1.0000000000 ];
c1_rd = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_rd = [   0.8125000000,   0.3437500000,   0.4687500000 ];
dd_rd = [   0.2812500000,   0.2812500000,   0.2812500000 ];
a11_sx = [   0.6875000000,   0.6875000000,   0.0000000000 ];
a12_sx = [  -0.6562500000,  -0.4062500000,   1.0000000000 ];
a21_sx = [   0.6875000000,   0.5625000000,   0.0000000000 ];
a22_sx = [   0.6875000000,   0.6875000000,   0.7187500000 ];
b1_sx = [   0.3437500000,   0.6875000000,   0.0000000000 ];
b2_sx = [   0.1250000000,   0.0625000000,   1.0000000000 ];
c1_sx = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_sx = [   0.8125000000,   0.3437500000,   0.4687500000 ];
dd_sx = [   0.2812500000,   0.2812500000,   0.2812500000 ];
a11_sxsd = [   0.5312500000,   0.7500000000,   0.0000000000 ];
a12_sxsd = [  -0.7500000000,  -0.3750000000,   1.0000000000 ];
a21_sxsd = [   0.7500000000,   0.5625000000,   0.0000000000 ];
a22_sxsd = [   0.7500000000,   0.7500000000,   0.7500000000 ];
b1_sxsd = [   0.3750000000,   0.7500000000,   0.0000000000 ];
b2_sxsd = [   0.1250000000,   0.0937500000,   1.0000000000 ];
c1_sxsd = [   0.3125000000,   0.0625000000,   0.0000000000 ];
c2_sxsd = [   0.7500000000,   0.3750000000,   0.4687500000 ];
dd_sxsd = [   0.2812500000,   0.2812500000,   0.2812500000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

