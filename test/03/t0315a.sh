#!/bin/sh

prog=directFIRhilbert_socp_mmsePW_test.m
depends="test/directFIRhilbert_socp_mmsePW_test.m test_common.m \
directFIRhilbert_socp_mmsePW.m \
directFIRhilbert_slb.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbertEsqPW.m \
directFIRhilbertA.m \
print_polynomial.m \
local_max.m"

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
cat > test_hM1_coef.ok << 'EOF'
hM1 = [  -0.00146262,  -0.00067865,  -0.00082830,  -0.00100706, ... 
         -0.00120131,  -0.00142861,  -0.00167499,  -0.00195830, ... 
         -0.00226508,  -0.00261409,  -0.00299211,  -0.00341801, ... 
         -0.00387842,  -0.00439393,  -0.00495228,  -0.00557391, ... 
         -0.00624753,  -0.00699539,  -0.00780917,  -0.00871157, ... 
         -0.00969836,  -0.01079596,  -0.01200333,  -0.01335478, ... 
         -0.01485669,  -0.01655410,  -0.01846781,  -0.02066392, ... 
         -0.02319287,  -0.02616498,  -0.02969193,  -0.03399320, ... 
         -0.03933969,  -0.04623879,  -0.05550800,  -0.06874029, ... 
         -0.08930006,  -0.12600327,  -0.21109396,  -0.63494039 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1_coef.ok "directFIRhilbert_socp_mmsePW_test_hM1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_coef.ok"; fail; fi

#
# this much worked
#
pass

