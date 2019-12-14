#!/bin/sh

prog=mcclellanFIRsymmetric_lowpass_test.m

depends="mcclellanFIRsymmetric_lowpass_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
directFIRsymmetricA.m"

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
cat > test_hM.ok << 'EOF'
hM = [  -0.0033553166,  -0.0060199941,  -0.0008095511,   0.0097517353, ... 
         0.0083169692,  -0.0113361240,  -0.0218294000,   0.0048235697, ... 
         0.0398905525,   0.0177620062,  -0.0583645385,  -0.0735965283, ... 
         0.0724127589,   0.3065832661,   0.4224244495 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_1_p.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

