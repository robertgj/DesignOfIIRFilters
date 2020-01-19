#!/bin/sh

prog=mcclellanFIRsymmetric_flat_bandpass_test.m

depends="mcclellanFIRsymmetric_flat_bandpass_test.m test_common.m \
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
hM = [     0.39943608,     2.80338673,     3.58407518,    -7.41566323, ... 
         -22.37323170,    -3.31190193,    55.11534337,    61.97517525, ... 
         -61.61045429,  -180.70783186,   -40.00386414,   291.97903758, ... 
         309.44254739,  -230.80783942,  -670.99959487,  -168.91581215, ... 
         855.41500883,   879.21217306,  -523.03354819, -1540.74407723, ... 
        -430.86063571,  1592.47581799,  1607.40567887,  -712.61622761, ... 
       -2202.61768935 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_flat_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

