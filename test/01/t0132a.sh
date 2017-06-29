#!/bin/sh

prog=simplex_OneMPA_lattice_test.m

depends="simplex_OneMPA_lattice_test.m test_common.m print_polynomial.m \
tf2schurOneMlattice.m truncation_test_common.m schurOneMPAlattice2tf.m \
schurOneMPAlattice_cost.m schurOneMscale.m flt2SD.m x2nextra.m tf2pa.m \
Abcd2tf.m schurOneMlattice2Abcd.oct spectralfactor.oct schurdecomp.oct \
schurexpand.oct bin2SD.oct"

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
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

