#!/bin/sh

prog=de_min_schurNSPAlattice_lowpass_test.m
depends="test/de_min_schurNSPAlattice_lowpass_test.m test_common.m \
truncation_test_common.m schurNSPAlattice2tf.m tf2schurNSlattice.m \
schurNSPAlattice_cost.m Abcd2tf.m flt2SD.m x2nextra.m tf2pa.m \
print_polynomial.m SDadders.m qroots.oct \
schurNSlattice2Abcd.oct spectralfactor.oct schurNSlattice2Abcd.oct \
schurNSscale.oct schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct"

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
use_best_de_min_found = 1
warning: Using the best filter found so far. Set "use_best_de_min_found"=false to re-run de_min.
warning: called from
    de_min_schurNSPAlattice_lowpass_test at line 26 column 3

cost_ex= 1.00080
cost_rd= 1.24590
cost_de= 0.78737
cost_sd= 3.60587
cost_desd= 1.18786
A1s20_rd = [  -0.8125000000,   0.7187500000 ]';
A1s00_rd = [   0.5937500000,   0.6875000000 ]';
A1s02_rd = [   0.8125000000,  -0.7187500000 ]';
A1s22_rd = [   0.5937500000,   0.6875000000 ]';
A2s20_rd = [  -0.7500000000,   0.9375000000,  -0.6875000000 ]';
A2s00_rd = [   0.6562500000,   0.3437500000,   0.7500000000 ]';
A2s02_rd = [   0.7500000000,  -0.9375000000,   0.6875000000 ]';
A2s22_rd = [   0.6562500000,   0.3437500000,   0.7500000000 ]';
A1s20_de = [  -0.7812500000,   0.7187500000 ]';
A1s00_de = [  -0.5625000000,   0.7812500000 ]';
A1s02_de = [   0.7812500000,  -0.7187500000 ]';
A1s22_de = [  -0.5625000000,   0.7812500000 ]';
A2s20_de = [  -0.7812500000,   0.8750000000,  -0.6875000000 ]';
A2s00_de = [  -0.6562500000,   0.3750000000,   0.8125000000 ]';
A2s02_de = [   0.7812500000,  -0.8750000000,   0.6875000000 ]';
A2s22_sd = [   0.6250000000,   0.3750000000,   0.7500000000 ]';
A1s20_sd = [  -0.7500000000,   0.7500000000 ]';
A1s00_sd = [   0.6250000000,   0.7500000000 ]';
A1s02_sd = [   0.7500000000,  -0.7500000000 ]';
A1s22_sd = [   0.6250000000,   0.7500000000 ]';
A2s20_sd = [  -0.7500000000,   0.9375000000,  -0.7500000000 ]';
A2s00_sd = [   0.6250000000,   0.3750000000,   0.7500000000 ]';
A2s02_sd = [   0.7500000000,  -0.9375000000,   0.7500000000 ]';
A2s22_sd = [   0.6250000000,   0.3750000000,   0.7500000000 ]';
A1s20_desd = [  -0.8750000000,   0.5312500000 ]';
A1s00_desd = [   0.7500000000,  -0.3750000000 ]';
A1s02_desd = [   0.7500000000,  -0.9687500000 ]';
A1s22_desd = [   0.7500000000,  -0.7500000000 ]';
A2s20_desd = [  -0.3750000000,  -0.9687500000,  -0.4687500000 ]';
A2s00_desd = [  -0.8750000000,   0.8750000000,  -0.7500000000 ]';
A2s02_desd = [   0.3125000000,  -0.7500000000,  -0.8750000000 ]';
A2s22_desd = [  -0.5000000000,   0.4687500000,   0.6250000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

