#!/bin/sh

prog=simplex_schurOneMPAlattice_lowpass_test.m

depends="test/simplex_schurOneMPAlattice_lowpass_test.m test_common.m \
print_polynomial.m \
tf2schurOneMlattice.m truncation_test_common.m schurOneMPAlattice2tf.m \
schurOneMPAlattice_cost.m schurOneMscale.m flt2SD.m x2nextra.m tf2pa.m \
Abcd2tf.m schurOneMlattice2Abcd.oct spectralfactor.oct schurdecomp.oct \
schurexpand.oct bin2SD.oct qroots.oct"

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
cost_rd= 1.10967
cost_sx= 1.10967
cost_sd= 3.90125
cost_sxsd= 3.17459
A1k_rd = [  -0.8125000000,   0.7187500000 ];
A2k_rd = [  -0.7500000000,   0.9375000000,  -0.6875000000 ];
A1k_sx = [  -0.8125000000,   0.7187500000 ];
A2k_sx = [  -0.7500000000,   0.9375000000,  -0.6875000000 ];
A1k_sd = [  -0.7500000000,   0.7500000000 ];
A2k_sd = [  -0.7500000000,   0.9375000000,  -0.7500000000 ];
A1k_sxsd = [  -0.7500000000,   0.7500000000 ];
A2k_sxsd = [  -0.7500000000,   0.8750000000,  -0.7500000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

