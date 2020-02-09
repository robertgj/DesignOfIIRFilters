#!/bin/sh

prog=directFIRsymmetricA_test.m

depends="directFIRsymmetricA_test.m test_common.m directFIRsymmetricA.m"

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
print_usage: 'A=directFIRsymmetricA(wa,hM)
[A,gradA]=directFIRsymmetricA(wa,hM)
A=directFIRsymmetricA(wa,hM,order)
[A,gradA]=directFIRsymmetricA(wa,hM,order)' not found
Too many input arguments!
print_usage: 'A=directFIRsymmetricA(wa,hM)
[A,gradA]=directFIRsymmetricA(wa,hM)
A=directFIRsymmetricA(wa,hM,order)
[A,gradA]=directFIRsymmetricA(wa,hM,order)' not found
Too many output arguments!
print_usage: 'A=directFIRsymmetricA(wa,hM)
[A,gradA]=directFIRsymmetricA(wa,hM)
A=directFIRsymmetricA(wa,hM,order)
[A,gradA]=directFIRsymmetricA(wa,hM,order)' not found
Caught empty hM!
hM is empty
Caught bad type!
Expected order to be "odd" or "even"
Caught bad type!
Expected order to be "odd" or "even"
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

