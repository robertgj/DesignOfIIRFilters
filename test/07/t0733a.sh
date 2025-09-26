#!/bin/sh

prog=socp_relaxation_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m
depends="test/socp_relaxation_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m \
test_common.m \
directFIRantisymmetric_socp_mmse.m \
directFIRantisymmetric_allocsd_Lim.m \
directFIRantisymmetric_slb.m \
directFIRantisymmetric_slb_constraints_are_empty.m \
directFIRantisymmetric_slb_exchange_constraints.m \
directFIRantisymmetric_slb_set_empty_constraints.m \
directFIRantisymmetric_slb_show_constraints.m \
directFIRantisymmetric_slb_update_constraints.m \
directFIRantisymmetricEsq.m \
directFIRantisymmetricA.m \
selesnickFIRantisymmetric_linear_differentiator.m \
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
cat > test_hM_min_coef.ok << 'EOF'
hM_min = [       -1,        1,        2,       -6, ... 
                  3,       14,      -22,       -7, ... 
                 56,      -44,      -74,      162, ... 
                 -3,     -350,      346,     1033 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_directFIRantisymmetric_lowpass_differentiator_12_nbits_test";

diff -Bb test_hM_min_coef.ok $nstr"_hM_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_min_coef.ok"; fail; fi

#
# this much worked
#
pass

