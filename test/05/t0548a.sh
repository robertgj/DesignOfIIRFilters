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
Ux=2,Vx=2,Mx=18,Qx=8,Rx=2
x = [  -0.0054181226, ...
       -0.9941990563,   1.2178853358, ...
       -0.3160107387,   0.4795544775, ...
        0.7332630420,   0.8755458812,   1.0778090250,   1.0890888967, ... 
        1.0940631645,   1.1305093074,   1.1552692179,   1.3558828246, ... 
        1.5174005215, ...
        2.0361605903,   1.7364261484,   1.6617240175,   0.2474499634, ... 
        2.7731237878,   2.0119986086,   2.3859352166,   0.8706417717, ... 
        1.1948809881, ...
        0.6490347273,   0.6538309572,   0.7945266158,   0.8381888053, ...
        1.6575948302,   2.1983420195,   1.1591864603,   2.6705104410 ]';
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

