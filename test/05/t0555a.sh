#!/bin/sh

prog=samin_schurOneMlattice_lowpass_test.m
depends="samin_schurOneMlattice_lowpass_test.m test_common.m \
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
use_best_siman_found = 1
warning: Using the best filter found so far. 
Set "use_best_siman_found"=false to re-run siman.
warning: called from
    samin_schurOneMlattice_lowpass_test at line 24 column 3

cost_ex= 1.00080
cost_rd= 1.52987
svec_rd_digits=21,svec_rd_adders=10
cost_sa= 1.46171
svec_sa = [ -24,  31, -28,  26, ... 
            -15,   2,   3,  21, ... 
              3,   4,   1 ]';
svec_sa_digits=21,svec_sa_adders=10
cost_sd= 2.71571
svec_sd_digits=19,svec_sd_adders=8
cost_sasd= 1.76726
svec_sasd = [ -24,  31, -28,  24, ... 
              -12,   2,   3,  24, ... 
                3,   4,   1 ]';
svec_sasd_digits=19,svec_sasd_adders=8
k_rd = [ -0.781250,  0.968750, -0.875000,  0.812500, ... 
         -0.468750 ];
c_rd = [  0.062500,  0.093750,  0.625000,  0.093750, ... 
          0.125000,  0.031250 ];
k_sa = [ -0.750000,  0.968750, -0.875000,  0.812500, ... 
         -0.468750 ];
c_sa = [  0.062500,  0.093750,  0.656250,  0.093750, ... 
          0.125000,  0.031250 ];
k_sd = [ -0.750000,  0.968750, -0.875000,  0.750000, ... 
         -0.468750 ];
c_sd = [  0.062500,  0.093750,  0.625000,  0.093750, ... 
          0.125000,  0.031250 ];
k_sasd = [ -0.750000,  0.968750, -0.875000,  0.750000, ... 
           -0.375000 ];
c_sasd = [  0.062500,  0.093750,  0.750000,  0.093750, ... 
            0.125000,  0.031250 ];
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

