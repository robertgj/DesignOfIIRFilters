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
x0 = [   0.0014696222, ...
         0.1199825824,   0.8795401210,   0.9057853850,   0.9877405435, ... 
         1.0000096805,   1.0404757763,   1.8132674074,   1.8230532946, ...
         2.5775700989,   1.3372096730,   0.5634732248,   1.6397954741, ... 
         0.1824249219,   2.3910505752,   0.0676187465,   1.5701722644, ...
         0.4006887279,   0.7468150323,   0.7625788897,   0.7807504296, ... 
         0.8614361408,   0.8699203563,   0.8911825217,   0.9067267473, ...
         0.7364316948,   1.3121448484,   1.0929799692,   0.8261490005, ... 
         0.5592650219,   1.3349136474,   0.5453121920,   1.4607718474 ]';
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

