#!/bin/sh

prog=tarczynski_bandpass_hilbert_test.m

depends="test/tarczynski_bandpass_hilbert_test.m test_common.m delayz.m \
print_polynomial.m print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m \
x2zp.m xInitHd.m iirA.m iirP.m iirT.m iirE.m fixResultNaN.m \
qroots.oct"

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
cat > test_x0.ok << 'EOF'
Ux0=0,Vx0=0,Mx0=16,Qx0=16,Rx0=1
x0 = [   0.0017939125, ...
         0.1156698219,   0.8300663261,   0.9201670141,   0.9804428804, ... 
         1.0000450593,   1.0357935731,   1.7965151254,   1.8084704832, ...
         2.5765665124,   1.3857816730,   0.5467334780,   1.6527845200, ... 
         0.2022415975,   2.3874820873,   0.1773909979,   1.5524068171, ...
         0.3958332005,   0.7047113285,   0.7735142375,   0.7846162970, ... 
         0.8131035069,   0.8429068709,   0.8571490958,   0.9200567882, ...
         0.7476204923,   1.3608986444,   1.1150149726,   0.8365664155, ... 
         1.4869085526,   1.3931710822,   0.5649154072,   0.5272299923 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x0.ok tarczynski_bandpass_hilbert_test_x0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x0.ok"; fail; fi


#
# this much worked
#
pass

