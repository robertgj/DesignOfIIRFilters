#!/bin/sh

prog=bitflip_schurOneMlattice_lowpass_test.m

depends="bitflip_schurOneMlattice_lowpass_test.m bitflip.oct test_common.m \
schurOneMlattice2tf.m truncation_test_common.m schurOneMlattice_cost.m \
tf2schurOneMlattice.m schurOneMlattice2Abcd.oct Abcd2tf.m print_polynomial.m \
schurOneMscale.m schurdecomp.oct schurexpand.oct flt2SD.m x2nextra.m bin2SD.oct"

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
norder =  5
dBpass =  1
dBstop =  40
fpass =  0.12500
fstop =  0.15000
nbits =  6
ndigits =  2
bitstart =  4
msize =  3
cost_ex= 1.00080
cost_rd= 1.52987
cost_bf= 1.52987
cost_sd= 2.71571
cost_bfsd= 2.15713
k_rd = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
          -0.4687500000 ];
c_rd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_bf = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
          -0.4687500000 ];
c_bf = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_sd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
          -0.4687500000 ];
c_sd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_bfsd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
            -0.4687500000 ];
c_bfsd = [   0.0937500000,   0.0937500000,   0.7500000000,   0.0937500000, ... 
             0.1250000000,   0.0312500000 ];
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

