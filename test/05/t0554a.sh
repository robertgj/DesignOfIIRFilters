#!/bin/sh

prog=samin_schurNSlattice_lowpass_test.m
depends="test/samin_schurNSlattice_lowpass_test.m test_common.m \
truncation_test_common.m schurNSlattice2tf.m schurNSlattice_cost.m Abcd2tf.m \
tf2schurNSlattice.m flt2SD.m x2nextra.m SDadders.m print_polynomial.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct schurNSlattice2Abcd.oct \
bin2SD.oct bin2SPT.oct"

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
use_best_siman_found = 1
warning: Using the best filter found so far. 
Set "use_best_siman_found"=false to re-run siman.
warning: called from
    samin_schurNSlattice_lowpass_test at line 24 column 3

cost_ex= 1.00080
cost_rd= 1.54321
svec_rd_digits=42,svec_rd_adders=22
cost_sa= 0.84197
svec_sa = [  32,  21,  11,   4, ... 
              1,   7,  23,  32, ... 
             16,  18, -25,  31, ... 
            -26,  25, -15,  20, ... 
             10,  15,  16,  31 ]';
svec_sa_digits=40,svec_sa_adders=20
cost_sd= 2.33728
svec_sd_digits=57,svec_sd_adders=27
cost_sasd= 0.83087
svec_sasd = [  31,  24,  12,   5, ... 
                1,   5,  24,  28, ... 
               16,  16, -24,  31, ... 
              -30,  24, -10,  20, ... 
                9,  15,  18,  30, ... 
               24, -32,  28, -24, ... 
               15,  20,   8,  17, ... 
               16,  28 ]';
svec_sasd_digits=54,svec_sasd_adders=24
s10_rd = [  0.968750,  0.687500,  0.343750,  0.125000, ... 
            0.031250 ]';
s11_rd = [  0.218750,  0.718750,  0.937500,  1.000000, ... 
            0.468750 ]';
s20_rd = [ -0.781250,  0.968750, -0.875000,  0.812500, ... 
           -0.468750 ]';
s00_rd = [  0.625000,  0.281250,  0.468750,  0.562500, ... 
            0.875000 ]';
s02_rd = [  0.781250, -0.968750,  0.875000, -0.812500, ... 
            0.468750 ]';
s22_rd = [  0.625000,  0.281250,  0.468750,  0.562500, ... 
            0.875000 ]';
s10_sa = [  1.000000,  0.656250,  0.343750,  0.125000, ... 
            0.031250 ]';
s11_sa = [  0.218750,  0.718750,  1.000000,  1.000000, ... 
            0.562500 ]';
s20_sa = [ -0.781250,  0.968750, -0.812500,  0.781250, ... 
           -0.468750 ]';
s00_sa = [  0.625000,  0.312500,  0.468750,  0.500000, ... 
            0.968750 ]';
s02_sa = [  0.781250, -0.968750,  0.812500, -0.781250, ... 
            0.468750 ]';
s22_sa = [  0.625000,  0.312500,  0.468750,  0.500000, ... 
            0.968750 ]';
s10_sd = [  0.968750,  0.750000,  0.375000,  0.125000, ... 
            0.031250 ]';
s11_sd = [  0.218750,  0.750000,  0.937500,  1.000000, ... 
            0.468750 ]';
s20_sd = [ -0.750000,  0.968750, -0.875000,  0.750000, ... 
           -0.468750 ]';
s00_sd = [  0.625000,  0.281250,  0.468750,  0.562500, ... 
            0.875000 ]';
s02_sd = [  0.750000, -0.968750,  0.875000, -0.750000, ... 
            0.468750 ]';
s22_sd = [  0.625000,  0.281250,  0.468750,  0.562500, ... 
            0.875000 ]';
s10_sasd = [  0.968750,  0.750000,  0.375000,  0.156250, ... 
              0.031250 ]';
s11_sasd = [  0.156250,  0.750000,  0.875000,  1.000000, ... 
              0.500000 ]';
s20_sasd = [ -0.750000,  0.968750, -0.937500,  0.750000, ... 
             -0.312500 ]';
s00_sasd = [  0.625000,  0.281250,  0.468750,  0.562500, ... 
              0.937500 ]';
s02_sasd = [  0.750000, -1.000000,  0.875000, -0.750000, ... 
              0.468750 ]';
s22_sasd = [  0.625000,  0.250000,  0.531250,  0.500000, ... 
              0.875000 ]';
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
