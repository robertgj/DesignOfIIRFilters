#!/bin/sh

prog=goldfarb_idnani_fir_minimum_phase_test.m

depends="test/goldfarb_idnani_fir_minimum_phase_test.m \
test_common.m goldfarb_idnani.m iirE.m iirA.m iirP.m iirT.m \
xConstraints.m tf2x.m zp2x.m x2zp.m x2tf.m fixResultNaN.m updateWchol.m 
armijo_kim.m invSVD.m sqp_bfgs.m updateWbfgs.m print_polynomial.m \
print_pole_zero.m qroots.m qzsolve.oct"

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
       -0.9990000000,  -0.8269571246, ...
        0.2566567898,   0.2993104930,   0.5453003942,   0.6484724573, ... 
        0.6540716981,   0.7502264282,   0.7963299319,   0.8156270990, ... 
        0.8205680284,   0.8223501030,   0.8258343275,   0.8517260248, ... 
        0.9239331032,   0.9951337265,   0.9990000000,   0.9990000000, ... 
        0.9990000000,   0.9990000000,   0.9990000000, ...
        2.2305904878,   0.9020259439,   1.6949934350,   2.6247471145, ... 
        0.9336486571,   2.1245814534,   2.3269888314,   2.1713151337, ... 
        0.1070466138,   2.1736184620,   2.8133404477,   2.4363597070, ... 
        1.6059938117,   0.0301525776,   0.3346969208,   0.7694322909, ... 
        1.6883688250,   2.5816616235,   2.8593039754 ]';
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
