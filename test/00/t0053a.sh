#!/bin/sh

prog=goldfarb_idnani_fir_minimum_phase_test.m

depends="test/goldfarb_idnani_fir_minimum_phase_test.m \
test_common.m goldfarb_idnani.m iirE.m iirA.m iirP.m iirT.m \
xConstraints.m tf2x.m zp2x.m x2zp.m x2tf.m fixResultNaN.m updateWchol.m 
armijo_kim.m invSVD.m sqp_bfgs.m updateWbfgs.m print_polynomial.m \
print_pole_zero.m qroots.oct"

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
cat > test_x_coef.ok << 'EOF'
Ux=2,Vx=0,Mx=38,Qx=0,Rx=1
x = [   0.0035335601, ...
       -0.9990000000,  -0.8269571252, ...
        0.2566567917,   0.2993104926,   0.5453003941,   0.6484724597, ... 
        0.6540717036,   0.7502264292,   0.7963299321,   0.8156270994, ... 
        0.8205680222,   0.8223501033,   0.8258343277,   0.8517260250, ... 
        0.9239331031,   0.9951337266,   0.9990000000,   0.9990000000, ... 
        0.9990000000,   0.9990000000,   0.9990000000, ...
        2.2305904878,   0.9020259446,   1.6949934351,   2.6247471127, ... 
        0.9336486518,   2.1245814544,   2.3269888296,   2.1713151340, ... 
        0.1070466163,   2.1736184612,   2.8133404473,   2.4363597034, ... 
        1.6059938067,   0.0301525756,   0.7694322903,   2.5816616223, ... 
        1.6883688228,   0.3346969205,   2.8593039754 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x_coef.ok goldfarb_idnani_fir_minimum_phase_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
