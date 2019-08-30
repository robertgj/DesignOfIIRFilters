#!/bin/sh

prog=directFIRsymmetric_slb_update_constraints_test.m
depends="directFIRsymmetric_slb_update_constraints_test.m test_common.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetricA.m directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_constraints_are_empty.m \
local_max.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
al=[ 1 93 298 401 517 612 735 866 1001 ]
au=[ 51 232 364 501 558 672 800 933 ]
al=[ 1 93 298 401 517 612 735 866 1001 ]
f(al)=[ 0.000000 0.046000 0.148500 0.200000 0.258000 0.305500 0.367000 0.432500 0.500000 ](fs=1)
Al=[ -40.146402 -39.999332 -0.900114 -0.899034 -46.145616 -46.135795 -46.163050 -46.131322 -46.167002 ](dB)
au=[ 51 232 364 501 558 672 800 933 ]
f(au)=[ 0.025000 0.115500 0.181500 0.250000 0.278500 0.335500 0.399500 0.466000 ](fs=1)
Au=[ -40.142479 0.814691 0.815962 -46.167002 -46.144488 -46.151006 -46.130941 -46.156615 ](dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
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

