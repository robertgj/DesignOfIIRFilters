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
x0 = [   0.0012299372, ...
         0.6067857986,   0.9182064272,   0.9183653111,   0.9922935811, ... 
         1.0447169759,   1.2483981235,   1.3378162591,   1.6334933226, ...
         1.8114660855,   0.0880624473,   0.4923504871,   0.2787712692, ... 
         1.8742126026,   2.4700822289,   2.0616779305,   0.3448223654, ...
         0.2365366574,   0.5262991721,   0.6781466873,   0.7107340867, ... 
         0.7382111976,   0.8123693446,   0.9269542937,   0.9339390065, ...
         1.1279874494,   0.5637515920,   1.1481446190,   1.0308600306, ... 
         0.6993334848,   1.3642168530,   0.3997288197,   0.4977077328 ]';
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

