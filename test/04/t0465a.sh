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
hM = [     346.6174393,    1384.1759764,     475.0397672,   -6894.9867351, ... 
        -12695.2181907,    7309.6402723,   47779.7574138,   34867.3658180, ... 
        -77730.9674673, -154784.1927737,    6678.4653510,  292558.9876402, ... 
        247910.0879215, -256448.0019794, -582855.1939345, -107334.9576096, ... 
        681059.0642255,  644221.8804970, -312203.9143812, -912262.6344293 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hA.ok << 'EOF'
hA = [  0.005288962392, -0.005029218937,  0.001698717395,  0.000837899810, ... 
       -0.006722826962, -0.007310340028,  0.003652712225,  0.008669566372, ... 
        0.000373708830, -0.002473206124,  0.003854128365, -0.003966841418, ... 
       -0.020504739337, -0.007257285427,  0.027139879204,  0.025442553022, ... 
       -0.010768618013, -0.017976446123,  0.000514558620, -0.018567051350, ... 
       -0.041227875018,  0.027796612785,  0.118120851465,  0.044099737518, ... 
       -0.146972969140, -0.162797555955,  0.068053509975,  0.222063151703 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_flat_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hA.ok selesnickFIRsymmetric_flat_bandpass_test_hA_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA.ok"; fail; fi

#
# this much worked
#
pass

