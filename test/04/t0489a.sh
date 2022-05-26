#!/bin/sh

prog=halleyFIRsymmetricA_test.m

depends="test/halleyFIRsymmetricA_test.m halleyFIRsymmetricA.m test_common.m \
local_max.m directFIRsymmetricA.m selesnickFIRsymmetric_flat_lowpass.m"

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
Not enough input arguments!
print_usage: 'wx=halleyFIRsymmetricA(wa,hM) (find peaks)
wx=halleyFIRsymmetricA(wa,hM,Ax) (find wx for values Ax)' not found
Too many input arguments!
halleyFIRsymmetricA: function called with too many inputs
Too many output arguments!
halleyFIRsymmetricA: function called with too many outputs
Caught empty hM!
hM is empty
use_remez_bandpass = 1
use_selesnick_flat_lowpass = 0
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

