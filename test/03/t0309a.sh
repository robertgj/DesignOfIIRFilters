#!/bin/sh

prog=branch_bound_directFIRhilbert_8_nbits_test.m
depends="branch_bound_directFIRhilbert_8_nbits_test.m test_common.m \
directFIRhilbertA.m \
directFIRhilbertEsqPW.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb.m \
directFIRhilbert_mmsePW.m \
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
hM_min = [        0,        0,        0,        0, ... 
                 -1,       -3,       -6,      -12, ... 
                -24,      -80 ]'/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_min.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.hM_min.ok \
     branch_bound_directFIRhilbert_8_nbits_test_hM_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_min.ok"; fail; fi

#
# this much worked
#
pass

