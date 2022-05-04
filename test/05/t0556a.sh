#!/bin/sh

prog=samin_schurNSPAlattice_lowpass_test.m
depends="samin_schurNSPAlattice_lowpass_test.m test_common.m \
truncation_test_common.m schurNSPAlattice2tf.m tf2schurNSlattice.m \
schurNSPAlattice_cost.m Abcd2tf.m flt2SD.m x2nextra.m tf2pa.m \
print_polynomial.m qroots.m SDadders.m \
qzsolve.oct schurNSlattice2Abcd.oct spectralfactor.oct schurNSlattice2Abcd.oct \
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
use_best_siman_found = 1
warning: Using the best filter found so far. 
Set "use_best_siman_found"=false to re-run samin.
warning: called from
    samin_schurNSPAlattice_lowpass_test at line 25 column 3

cost_ex= 1.00080
cost_rd= 1.24590
svec_rd_digits=27,svec_rd_adders=17
cost_sa= 0.82945
svec_sa = [ -26,  23,  17,  24, ... 
            -25,  29, -22,  21, ... 
             11,  25 ]';
svec_sa_digits=28,svec_sa_adders=18
cost_sd= 3.60587
svec_sd_digits=40,svec_sd_adders=20
cost_sasd= 1.08412
svec_sasd = [ -28,  24,  15,  24, ... 
               24, -24,  20,  24, ... 
              -24,  28, -24,  20, ... 
               10,  28,  24, -31, ... 
               24,  20,  12,  24 ]';
svec_sasd_digits=40,svec_sasd_adders=20
A1s20_rd = [ -0.812500,  0.718750 ]';
A1s00_rd = [  0.593750,  0.687500 ]';
A1s02_rd = [  0.812500, -0.718750 ]';
A1s22_rd = [  0.593750,  0.687500 ]';
A2s20_rd = [ -0.750000,  0.937500, -0.687500 ]';
A2s00_rd = [  0.656250,  0.343750,  0.750000 ]';
A2s02_rd = [  0.750000, -0.937500,  0.687500 ]';
A2s22_rd = [  0.656250,  0.343750,  0.750000 ]';
A1s20_sa = [ -0.812500,  0.718750 ]';
A1s00_sa = [  0.531250,  0.750000 ]';
A1s02_sa = [  0.812500, -0.718750 ]';
A1s22_sa = [  0.531250,  0.750000 ]';
A2s20_sa = [ -0.781250,  0.906250, -0.687500 ]';
A2s00_sa = [  0.656250,  0.343750,  0.781250 ]';
A2s02_sa = [  0.781250, -0.906250,  0.687500 ]';
A2s22_sd = [  0.625000,  0.375000,  0.750000 ]';
A1s20_sd = [ -0.750000,  0.750000 ]';
A1s00_sd = [  0.625000,  0.750000 ]';
A1s02_sd = [  0.750000, -0.750000 ]';
A1s22_sd = [  0.625000,  0.750000 ]';
A2s20_sd = [ -0.750000,  0.937500, -0.750000 ]';
A2s00_sd = [  0.625000,  0.375000,  0.750000 ]';
A2s02_sd = [  0.750000, -0.937500,  0.750000 ]';
A2s22_sd = [  0.625000,  0.375000,  0.750000 ]';
A1s20_sasd = [ -0.875000,  0.750000 ]';
A1s00_sasd = [  0.468750,  0.750000 ]';
A1s02_sasd = [  0.750000, -0.750000 ]';
A1s22_sasd = [  0.625000,  0.750000 ]';
A2s20_sasd = [ -0.750000,  0.875000, -0.750000 ]';
A2s00_sasd = [  0.625000,  0.312500,  0.875000 ]';
A2s02_sasd = [  0.750000, -0.968750,  0.750000 ]';
A2s22_sasd = [  0.625000,  0.375000,  0.750000 ]';
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

