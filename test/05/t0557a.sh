#!/bin/sh

prog=samin_schurOneMPAlattice_lowpass_test.m
depends="samin_schurOneMPAlattice_lowpass_test.m \
test_common.m truncation_test_common.m schurOneMPAlattice_cost.m \
schurOneMPAlattice2tf.m tf2schurOneMlattice.m schurOneMscale.m Abcd2tf.m \
flt2SD.m x2nextra.m tf2pa.m print_polynomial.m qroots.m SDadders.m \
schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct qzsolve.oct \
schurOneMlattice2Abcd.oct spectralfactor.oct"

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
    samin_schurOneMPAlattice_lowpass_test at line 24 column 3

cost_ex= 1.00080
cost_rd= 1.10967
svec_rd_digits=13,svec_rd_adders=8
cost_sa= 0.88034
svec_sa = [ -26,  20, -25,  29, ... 
            -19 ]';
svec_sa_digits=14,svec_sa_adders=9
cost_sd= 3.90125
svec_sd_digits=10,svec_sd_adders=5
cost_sasd= 1.67064
svec_sasd = [ -28,  20, -24,  30, ... 
              -20 ]';
svec_sasd_digits=10,svec_sasd_adders=5
A1k_rd = [ -0.812500,  0.718750 ];
A2k_rd = [ -0.750000,  0.937500, -0.687500 ];
A1k_sa = [ -0.812500,  0.625000 ];
A2k_sa = [ -0.781250,  0.906250, -0.593750 ];
A1k_sd = [ -0.750000,  0.750000 ];
A2k_sd = [ -0.750000,  0.937500, -0.750000 ];
A1k_sasd = [ -0.875000,  0.625000 ];
A2k_sasd = [ -0.750000,  0.937500, -0.625000 ];
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

