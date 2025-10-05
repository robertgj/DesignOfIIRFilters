#!/bin/sh

prog=branch_bound_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m
depends="test/branch_bound_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m \
test_common.m \
selesnickFIRantisymmetric_linear_differentiator.m \
directFIRantisymmetric_socp_mmse.m \
directFIRantisymmetric_allocsd_Lim.m \
directFIRantisymmetricEsq.m \
directFIRantisymmetricA.m \
print_polynomial.m local_max.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
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
                  3,       16,      -22,       -7, ... 
                 56,      -44,      -74,      162, ... 
                 -3,     -349,      346,     1033 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_min_coef.ok"; fail; fi

cat > test_cost.ok << 'EOF'
Floating-point(31) & 1.0770e-04 & & \\
Floating-point(16) & 1.0771e-04 & & \\
13-bit 3-signed-digit & 1.1055e-04 & 37 & 21 \\
13-bit 3-signed-digit(Lim)&1.0830e-04 & 39 & 23 \\
13-bit 3-signed-digit(SOCP-relax) & 1.0830e-04 & 39 & 23 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="branch_bound_directFIRantisymmetric_lowpass_differentiator_12_nbits_test";

diff -Bb test_hM_min_coef.ok $nstr"_hM_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_min_coef.ok"; fail; fi

diff -Bb test_cost.ok $nstr"_cost.tab"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_cost.ok"; fail; fi

#
# this much worked
#
pass

