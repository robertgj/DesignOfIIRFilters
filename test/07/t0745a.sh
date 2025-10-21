#!/bin/sh

prog=socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test.m
depends="test/socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test.m \
../directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m \
test_common.m \
directFIRnonsymmetric_socp_mmse.m \
directFIRnonsymmetric_allocsd_Ito.m \
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
cat > test_h_min_coef.ok << 'EOF'
h_min = [       -2,      -24,       -4,       -8, ... 
               -71,      -97,       -1,      126, ... 
               112,        4,       82,      342, ... 
               335,     -248,     -941,     -908, ... 
                -4,      901,      944,      256, ... 
              -346,     -352,      -88,       -8, ... 
              -120,     -144,      -14,       96, ... 
                82,      -48,       48 ]'/4096;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_min_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test"

diff -Bb test_h_min_coef.ok $nstr"_h_min_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_min_coef.ok"; fail; fi

#
# this much worked
#
pass

