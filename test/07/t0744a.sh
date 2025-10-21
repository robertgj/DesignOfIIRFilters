#!/bin/sh

prog=branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test.m
depends="test/branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test.m \
../directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m \
test_common.m \
directFIRnonsymmetric_allocsd_Ito.m \
directFIRnonsymmetricAsq.m directFIRnonsymmetricP.m directFIRnonsymmetricT.m \
directFIRnonsymmetricEsq.m local_max.m print_polynomial.m \
flt2SD.m SDadders.m x2nextra.m bin2SDul.m bin2SD.oct bin2SPT.oct"

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
cat > test.h_min.ok << 'EOF'
h_min = [       -1,      -24,       -4,       -8, ... 
               -72,      -97,       -2,      126, ... 
               112,        4,       84,      343, ... 
               334,     -248,     -942,     -909, ... 
                -4,      902,      944,      256, ... 
              -347,     -353,      -92,       -8, ... 
              -120,     -144,      -12,       96, ... 
                82,      -48,       48 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.h_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test

diff -Bb test.h_min.ok $nstr"_h_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.h_min.ok"; fail; fi

#
# this much worked
#
pass

