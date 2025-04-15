#!/bin/sh

prog=tarczynski_bandpass_R2_test.m

depends="test/tarczynski_bandpass_R2_test.m test_common.m delayz.m print_polynomial.m \
print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m qroots.oct"

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
cat > test_x.ok << 'EOF'
Ux=2,Vx=0,Mx=18,Qx=10,Rx=2
x = [  -0.0035159065, ...
        0.1359720748,   0.4714889203, ...
        0.7798300450,   0.9182414755,   0.9670696491,   1.0229306062, ... 
        1.1135432590,   1.1804015932,   1.1971696743,   1.3469240267, ... 
        1.6388683604, ...
        2.4308499956,   1.8180169672,   3.0646639998,   0.2898414564, ... 
        1.6587386071,   2.0131110828,   2.3826704973,   0.9046302707, ... 
        1.2967439903, ...
        0.7351544537,   0.7527588363,   0.7739437347,   0.9103618171, ... 
        0.9105193469, ...
        1.9241288330,   2.3459847169,   1.5038572235,   2.6782025038, ... 
        1.1789903357 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x.ok tarczynski_bandpass_R2_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x.ok"; fail; fi


#
# this much worked
#
pass

