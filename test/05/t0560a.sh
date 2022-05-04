#!/bin/sh

prog=de_min_schurOneMlattice_lowpass_test.m
depends="de_min_schurOneMlattice_lowpass_test.m test_common.m \
truncation_test_common.m schurOneMlattice2tf.m tf2schurOneMlattice.m \
schurOneMlattice_cost.m Abcd2tf.m print_polynomial.m schurOneMscale.m \
SDadders.m x2nextra.m flt2SD.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct"

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
warning: Using the best filter found so far. 
           Set "use_best_de_min_found"=false to re-run de_min.
warning: called from
    de_min_schurOneMlattice_lowpass_test at line 25 column 3

cost_ex= 1.00080
cost_rd= 1.52987
cost_de= 1.27651
cost_sd= 2.71571
cost_desd= 1.91468
k_rd = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
          -0.4687500000 ];
c_rd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_de = [  -0.7500000000,   0.4062500000,   0.7500000000,  -0.7812500000, ... 
           0.3750000000 ];
c_de = [   0.1562500000,   0.1562500000,   0.1875000000,   0.4375000000, ... 
           0.0625000000,   0.0312500000 ];
k_sd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
          -0.4687500000 ];
c_sd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_desd = [   0.5000000000,  -0.7500000000,   0.9375000000,  -0.8750000000, ... 
             0.6250000000 ];
c_desd = [   0.0000000000,  -0.0937500000,  -0.1250000000,  -0.5625000000, ... 
            -0.0625000000,  -0.0312500000 ];
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

