#!/bin/sh

prog=directFIRsymmetric_slb_exchange_constraints_test.m
depends="test/directFIRsymmetric_slb_exchange_constraints_test.m \
test_common.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_mmsePW.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
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
vR before exchange constraints:
al=[ 1 93 298 401 ]
f(al)=[ 0.000000 0.046000 0.148500 0.200000 ](fs=1)
Al=[ -45.000000 -45.000000 -0.500000 -0.500000 ](dB)
au=[ 51 232 364 ]
f(au)=[ 0.025000 0.115500 0.181500 ](fs=1)
Au=[ -45.000000 0.000000 0.000000 ](dB)
vS before exchange constraints:
al=[ 201 318 533 ]
f(al)=[ 0.100000 0.158500 0.266000 ](fs=1)
Al=[ -2.568428 -0.741058 -37.887813 ](dB)
au=[ 253 376 501 584 ]
f(au)=[ 0.126000 0.187500 0.250000 0.291500 ](fs=1)
Au=[ 0.414948 0.092945 -27.921622 -42.954606 ](dB)
No vR constraints violated. No exchange with vS.
vR after exchange constraints:
al=[ 1 93 298 401 ]
f(al)=[ 0.000000 0.046000 0.148500 0.200000 ](fs=1)
Al=[ -45.000000 -45.000000 -0.500000 -0.500000 ](dB)
au=[ 51 232 364 ]
f(au)=[ 0.025000 0.115500 0.181500 ](fs=1)
Au=[ -45.000000 0.000000 0.000000 ](dB)
vS after exchange constraints:
al=[ 201 318 533 ]
f(al)=[ 0.100000 0.158500 0.266000 ](fs=1)
Al=[ -2.568428 -0.741058 -37.887813 ](dB)
au=[ 253 376 501 584 ]
f(au)=[ 0.126000 0.187500 0.250000 0.291500 ](fs=1)
Au=[ 0.414948 0.092945 -27.921622 -42.954606 ](dB)
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

