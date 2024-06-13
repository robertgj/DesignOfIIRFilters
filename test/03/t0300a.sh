#!/bin/sh

prog=directFIRsymmetric_bandpass_allocsd_test.m
depends="test/directFIRsymmetric_bandpass_allocsd_test.m test_common.m \
directFIRsymmetric_allocsd_Ito.m \
directFIRsymmetric_allocsd_Lim.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_mmsePW.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
local_max.m print_polynomial.m flt2SD.m x2nextra.m SDadders.m bin2SDul.m \
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
cat > test_2_12_hM_Lim.ok << 'EOF'
hM_Lim_12_bits = [        0,      -24,      -40,      -16, ... 
                         48,       71,       32,       -8, ... 
                         32,       84,        0,     -240, ... 
                       -352,     -136,      296,      520 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Lim.ok"; fail; fi

cat > test_2_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [       -1,      -24,      -40,      -16, ... 
                         48,       72,       32,       -8, ... 
                         32,       84,       -4,     -240, ... 
                       -360,     -136,      296,      520 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_2_12_hM_Ito.ok"; fail; fi

cat > test_3_12_hM_Lim.ok << 'EOF'
hM_Lim_12_bits = [        0,      -23,      -40,      -14, ... 
                         44,       71,       32,       -7, ... 
                         32,       85,       -4,     -238, ... 
                       -360,     -137,      297,      520 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_hM_Lim.ok"; fail; fi

cat > test_3_12_hM_Ito.ok << 'EOF'
hM_Ito_12_bits = [       -1,      -23,      -40,      -16, ... 
                         44,       72,       32,       -8, ... 
                         32,       85,       -4,     -240, ... 
                       -360,     -136,      296,      520 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_3_12_hM_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="directFIRsymmetric_bandpass_allocsd_test"

diff -Bb test_2_12_hM_Lim.ok $nstr"_2_ndigits_12_nbits_hM_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_hM_Lim.ok"; fail; fi
diff -Bb test_2_12_hM_Ito.ok $nstr"_2_ndigits_12_nbits_hM_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_2_12_hM_Ito.ok"; fail; fi

diff -Bb test_3_12_hM_Lim.ok $nstr"_3_ndigits_12_nbits_hM_Lim_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_hM_Lim.ok"; fail; fi
diff -Bb test_3_12_hM_Ito.ok $nstr"_3_ndigits_12_nbits_hM_Ito_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_3_12_hM_Ito.ok"; fail; fi

#
# this much worked
#
pass

