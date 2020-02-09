#!/bin/sh

prog=selesnickFIRsymmetric_flat_bandpass_test.m

depends="selesnickFIRsymmetric_flat_bandpass_test.m test_common.m \
selesnickFIRsymmetric_flat_bandpass.m lagrange_interp.m print_polynomial.m \
local_max.m xfr2tf.m directFIRsymmetricA.m"

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
hM = [     346.6174396,    1384.1759768,     475.0397670,   -6894.9867361, ... 
        -12695.2181917,    7309.6402729,   47779.7574159,   34867.3658189, ... 
        -77730.9674694, -154784.1927768,    6678.4653514,  292558.9876446, ... 
        247910.0879245, -256448.0019825, -582855.1939405, -107334.9576105, ... 
        681059.0642316,  644221.8805024, -312203.9143838, -912262.6344367 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_flat_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

