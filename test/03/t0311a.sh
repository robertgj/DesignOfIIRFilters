#!/bin/sh

prog=directFIRhilbert_slb_update_constraints_test.m
depends="directFIRhilbert_slb_update_constraints_test.m test_common.m \
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
echo $here
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
Adl=[ 0 0 0.99426 0.99426 0.99426 0.99426 0 0 ]
Wa=[ 0 0 1 1 1 1 0 0 ]
al=[ 101 ]
au=[ 126 188 314 439 ]
al=[ 101 ]
f(al)=[ 0.050000 ](fs=1)
Al=[ -0.074510 ](dB)
au=[ 126 188 314 439 ]
f(au)=[ 0.062500 0.093500 0.156500 0.219000 ](fs=1)
Au=[ 0.032237 0.018852 0.026035 0.024670 ](dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

