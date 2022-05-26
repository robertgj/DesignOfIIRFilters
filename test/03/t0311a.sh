#!/bin/sh

prog=directFIRhilbert_slb_update_constraints_test.m
depends="test/directFIRhilbert_slb_update_constraints_test.m test_common.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbertA.m directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_constraints_are_empty.m \
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
cat > test.ok << 'EOF'
fa=[ 0 0.0495 0.05 0.0505 0.4495 0.45 0.4505 0.4995 ]
Adu=[ 0 0 -0.99426 -0.99426 -0.99426 -0.99426 0 0 ]
Adl=[ -1 -1 -1 -1 -1 -1 -1 -1 ]
Wa=[ 0 0 1 1 1 1 0 0 ]
al=[ 150 309 437 ]
au=[ 101 ]
al=[ 150 309 437 ]
f(al)=[ 0.074500 0.154000 0.218000 ](fs=1)
Al=[ 0.046565 0.030980 0.028323 ](dB)
au=[ 101 ]
f(au)=[ 0.050000 ](fs=1)
Au=[ -0.192207 ](dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

