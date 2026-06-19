#!/bin/sh

prog=socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test.m
depends="test/socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test.m \
../directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m \
test_common.m \
directFIRnonsymmetric_socp_mmse.m \
directFIRnonsymmetric_allocsd_Lim.m \
directFIRnonsymmetric_slb.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_update_constraints.m \
directFIRnonsymmetricEsq.m \
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricP.m \
directFIRnonsymmetricT.m \
print_polynomial.m \
local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
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
cat > test_h_sd_coef.ok << 'EOF'
h_sd = [       -2,      -12,       -2,       -5, ... 
              -36,      -49,        0,       64, ... 
               56,        4,       42,      168, ... 
              168,     -124,     -472,     -456, ... 
               -3,      452,      472,      121, ... 
             -176,     -176,      -44,       -7, ... 
              -60,      -71,       -7,       48, ... 
               42,      -24,       24 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_sd_coef.ok"; fail; fi

cat > test_h_Lim_sd_coef.ok << 'EOF'
h_Lim_sd = [       -2,      -12,       -2,       -5, ... 
                  -36,      -49,        0,       64, ... 
                   56,        4,       42,      171, ... 
                  166,     -124,     -471,     -454, ... 
                    0,      451,      470,      121, ... 
                 -172,     -176,      -44,       -7, ... 
                  -60,      -71,       -7,       48, ... 
                   40,      -24,       24 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_Lim_coef.ok"; fail; fi

cat > test_h_min_coef.ok << 'EOF'
h_min = [       -2,      -12,       -2,       -5, ... 
               -36,      -49,        0,       64, ... 
                56,        3,       42,      171, ... 
               167,     -124,     -471,     -455, ... 
                 0,      451,      470,      121, ... 
              -172,     -176,      -46,       -6, ... 
               -60,      -71,       -7,       48, ... 
                40,      -23,       24 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test"

diff -Bb test_h_sd_coef.ok $nstr"_h_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_sd_coef.ok"; fail; fi

diff -Bb test_h_Lim_sd_coef.ok $nstr"_h_Lim_sd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_Lim_sd_coef.ok"; fail; fi

diff -Bb test_h_min_coef.ok $nstr"_h_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_min_coef.ok"; fail; fi

#
# this much worked
#
pass

