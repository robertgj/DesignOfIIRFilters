#!/bin/sh

prog=samin_svcasc_lowpass_test.m
depends="test/samin_svcasc_lowpass_test.m \
test_common.m truncation_test_common.m sos2pq.m pq2svcasc.m svcasc2tf.m \
svcasc_cost.m flt2SD.m x2nextra.m print_polynomial.m qroots.oct SDadders.m \
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
    samin_svcasc_lowpass_test at line 25 column 3

cost_ex= 1.00080
cost_rd= 1.23622
svec_rd_digits=54,svec_rd_adders=31
cost_sa= 0.67806
svec_sa = [  24,  22, -22, -12, ... 
             16,  21,  17,  20, ... 
             22,  22,  13,  21, ... 
              4,   2,  16,  12, ... 
              2,  30,  13,  13, ... 
              8,   9,   7 ]';
svec_sa_digits=49,svec_sa_adders=26
cost_sd=     Inf
svec_sd_digits=42,svec_sd_adders=19
cost_sasd=     Inf
svec_sasd = [  24,  24, -24, -12, ... 
               16,  24,  18,  24, ... 
               24,  24,  12,  24, ... 
                4,   3,  16,  10, ... 
                2,  24,  12,  15, ... 
                9,   9,   9 ]';
svec_sasd_digits=42,svec_sasd_adders=19
a11_rd = [  0.687500,  0.687500,  0.000000 ];
a12_rd = [ -0.687500, -0.406250,  1.000000 ];
a21_rd = [  0.687500,  0.562500,  0.000000 ];
a22_rd = [  0.687500,  0.687500,  0.718750 ];
b1_rd = [  0.343750,  0.687500,  0.000000 ];
b2_rd = [  0.125000,  0.093750,  1.000000 ];
c1_rd = [  0.312500,  0.062500,  0.000000 ];
c2_rd = [  0.812500,  0.343750,  0.468750 ];
dd_rd = [  0.281250,  0.281250,  0.281250 ];
a11_sa = [  0.750000,  0.687500,  0.000000 ];
a12_sa = [ -0.687500, -0.375000,  1.000000 ];
a21_sa = [  0.656250,  0.531250,  0.000000 ];
a22_sa = [  0.625000,  0.687500,  0.687500 ];
b1_sa = [  0.406250,  0.656250,  0.000000 ];
b2_sa = [  0.125000,  0.062500,  1.000000 ];
c1_sa = [  0.375000,  0.062500,  0.000000 ];
c2_sa = [  0.937500,  0.406250,  0.406250 ];
dd_sa = [  0.250000,  0.281250,  0.218750 ];
a11_sasd = [  0.750000,  0.750000,  0.000000 ];
a12_sasd = [ -0.750000, -0.375000,  1.000000 ];
a21_sasd = [  0.750000,  0.562500,  0.000000 ];
a22_sasd = [  0.750000,  0.750000,  0.750000 ];
b1_sasd = [  0.375000,  0.750000,  0.000000 ];
b2_sasd = [  0.125000,  0.093750,  1.000000 ];
c1_sasd = [  0.312500,  0.062500,  0.000000 ];
c2_sasd = [  0.750000,  0.375000,  0.468750 ];
dd_sasd = [  0.281250,  0.281250,  0.281250 ];
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

