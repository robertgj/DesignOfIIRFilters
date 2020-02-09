#!/bin/sh

prog=branch_bound_directFIRhilbert_bandpass_12_nbits_test.m
depends="branch_bound_directFIRhilbert_bandpass_12_nbits_test.m test_common.m \
directFIRhilbertA.m directFIRhilbertEsqPW.m directFIRhilbert_allocsd_Ito.m \
local_max.m print_polynomial.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
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
cat > test.hM_min.ok << 'EOF'
hM_min = [      -24,        8,       64,      -32, ... 
               -128,      120,      327,     -872 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_min.ok"; fail; fi

cat > test.hM_sd.ok << 'EOF'
hM_sd = [      -20,        8,       64,      -32, ... 
              -128,      112,      327,     -868 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_sd.ok"; fail; fi

cat > test.cost.ok << 'EOF'
Exact &   4.99e-05 & & \\
12-bit 2-signed-digit &   5.39e-04 & 16 & 8 \\
12-bit 2-signed-digit(Ito) &   7.91e-05 & 16 & 8 \\
12-bit 2-signed-digit(branch-and-bound)&  4.96e-05 & 16 & 8 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.hM_min.ok \
     branch_bound_directFIRhilbert_bandpass_12_nbits_test_hM_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_min.ok"; fail; fi

diff -Bb test.hM_sd.ok \
     branch_bound_directFIRhilbert_bandpass_12_nbits_test_hM_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_sd.ok"; fail; fi

diff -Bb test.cost.ok \
     branch_bound_directFIRhilbert_bandpass_12_nbits_test_cost.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.cost.ok"; fail; fi

#
# this much worked
#
pass

