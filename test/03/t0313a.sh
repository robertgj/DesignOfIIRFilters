#!/bin/sh

prog=branch_bound_directFIRhilbert_12_nbits_test.m
depends="branch_bound_directFIRhilbert_12_nbits_test.m test_common.m \
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
hM_min = [       -1,       -1,       -1,       -1, ... 
                 -2,       -2,       -2,       -3, ... 
                 -4,       -4,       -4,       -4, ... 
                 -8,       -8,       -8,       -8, ... 
                -12,      -12,      -16,      -16, ... 
                -18,      -20,      -24,      -28, ... 
                -30,      -32,      -36,      -40, ... 
                -48,      -52,      -60,      -68, ... 
                -80,      -96,     -112,     -140, ... 
               -184,     -258,     -432,    -1304 ]'/2048;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.hM_min.ok \
     branch_bound_directFIRhilbert_12_nbits_test_hM_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_min.ok"; fail; fi

#
# this much worked
#
pass

