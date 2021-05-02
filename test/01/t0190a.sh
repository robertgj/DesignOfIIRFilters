#!/bin/sh

prog=simplex_schurOneMlattice_lowpass_test.m

depends="simplex_schurOneMlattice_lowpass_test.m test_common.m print_polynomial.m \
schurOneMlattice2tf.m truncation_test_common.m schurOneMlattice_cost.m \
tf2schurOneMlattice.m schurOneMlattice2Abcd.oct Abcd2tf.m \
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
cost_rd= 1.52987
cost_sx= 1.46171
cost_sd= 2.71571
cost_sxsd= 2.39176
k_rd = [  -0.7812500000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
          -0.4687500000 ];
c_rd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_sx = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.8125000000, ... 
          -0.4687500000 ];
c_sx = [   0.0625000000,   0.0937500000,   0.6562500000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_sd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
          -0.4687500000 ];
c_sd = [   0.0625000000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
           0.1250000000,   0.0312500000 ];
k_sxsd = [  -0.7500000000,   0.9687500000,  -0.8750000000,   0.7500000000, ... 
            -0.4375000000 ];
c_sxsd = [   0.0937500000,   0.0937500000,   0.6250000000,   0.0937500000, ... 
             0.1250000000,   0.0312500000 ];
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

